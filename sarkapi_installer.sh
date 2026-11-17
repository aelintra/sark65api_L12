#!/bin/sh
#
# sarkapi_installer.sh — install sark65api_L12 onto an existing SARK V65 PBX.
# Source of truth for steps: docs/installation.md
#
# Supports Laravel 12 / PHP 8.3 on Ubuntu 24.04 SARK appliances.
# Run as root from the application tree, for example:
#
#   cd /opt
#   git clone https://github.com/aelintra/sark65api_L12.git sark65api_L12
#   cd /opt/sark65api_L12
#   ./sarkapi_installer.sh
#
# Or, if the tree is already present:
#
#   cd /opt/sark65api_L12 && sudo ./sarkapi_installer.sh
#
set -eu

APP_NAME='sark65api_L12'
DEFAULT_APP_DIR="/opt/${APP_NAME}"
API_PORT='44300'
SHOREWALL_RULE="ACCEPT net \$FW tcp ${API_PORT} - - # sark65 API"
SHOREWALL_RULES='/etc/shorewall/sark_rules'

die() {
  echo "ERROR: $*" >&2
  exit 1
}

info() {
  echo "==> $*"
}

require_root() {
  [ "$(id -u)" -eq 0 ] || die "run as root (sudo ./sarkapi_installer.sh)"
}

resolve_app_dir() {
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  if [ -f "${SCRIPT_DIR}/artisan" ] && [ -f "${SCRIPT_DIR}/composer.json" ]; then
    APP_DIR="${SCRIPT_DIR}"
  elif [ -f "${DEFAULT_APP_DIR}/artisan" ]; then
    APP_DIR="${DEFAULT_APP_DIR}"
  else
    die "application tree not found. Clone into ${DEFAULT_APP_DIR} first, then re-run from that directory."
  fi
  cd "${APP_DIR}"
  info "Using application directory: ${APP_DIR}"
}

check_sark() {
  [ -d /opt/sark ] || die "/opt/sark missing — install SARK V65 before this API"
  [ -f /opt/sark/db/sark.db ] || die "/opt/sark/db/sark.db missing — SARK database not found"
  command -v php >/dev/null 2>&1 || die "php not found"
  command -v apache2ctl >/dev/null 2>&1 || die "apache2ctl not found"

  PHP_MAJOR=$(php -r 'echo PHP_MAJOR_VERSION;')
  PHP_MINOR=$(php -r 'echo PHP_MINOR_VERSION;')
  if [ "${PHP_MAJOR}" -lt 8 ] || { [ "${PHP_MAJOR}" -eq 8 ] && [ "${PHP_MINOR}" -lt 2 ]; }; then
    die "PHP ${PHP_MAJOR}.${PHP_MINOR} found; need PHP 8.2+ (SARK V65 ships 8.3)"
  fi
  info "SARK V65 present; PHP $(php -r 'echo PHP_VERSION;')"
}

install_os_packages() {
  info "Installing OS packages (git, php-zip, unzip)"
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y git php-zip unzip
  a2enmod ssl rewrite headers >/dev/null
}

install_composer() {
  if command -v composer >/dev/null 2>&1; then
    info "Composer already installed: $(composer --version 2>/dev/null | head -n1)"
    return
  fi
  info "Installing Composer to /usr/local/bin/composer"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  php -r "unlink('composer-setup.php');"
  composer --version
}

install_php_deps() {
  info "composer install --no-dev --optimize-autoloader"
  # Platform is pinned to 8.3.6 in composer.json so Symfony 8 is not pulled.
  composer install --no-dev --optimize-autoloader --no-interaction
}

configure_env() {
  if [ ! -f .env ]; then
    info "Creating .env from .env.example (production appliance defaults)"
    cp .env.example .env
  else
    info ".env already present — leaving values, ensuring appliance drivers"
  fi

  # Detect a usable APP_URL host (prefer hostname -I first address).
  HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  if [ -z "${HOST_IP}" ]; then
    HOST_IP='YOUR_PBX_FQDN_OR_IP'
  fi
  APP_URL_VALUE="https://${HOST_IP}:${API_PORT}"

  # Portable-ish in-place edits for common .env keys.
  set_env() {
    key=$1
    value=$2
    if grep -q "^${key}=" .env; then
      sed -i "s|^${key}=.*|${key}=${value}|" .env
    else
      printf '%s=%s\n' "${key}" "${value}" >> .env
    fi
  }

  set_env APP_ENV production
  set_env APP_DEBUG false
  set_env APP_URL "${APP_URL_VALUE}"
  set_env DB_CONNECTION sqlite
  set_env SESSION_DRIVER file
  set_env CACHE_STORE file
  set_env QUEUE_CONNECTION sync

  if ! grep -q '^APP_KEY=base64:' .env; then
    info "Generating APP_KEY"
    php artisan key:generate --force
  else
    info "APP_KEY already set"
  fi
}

link_database() {
  info "Linking database/database.sqlite -> /opt/sark/db/sark.db"
  mkdir -p database
  rm -f database/database.sqlite
  ln -s /opt/sark/db/sark.db database/database.sqlite
  ls -l database/database.sqlite
}

set_ownership() {
  info "Setting www-data ownership on storage, bootstrap/cache, public"
  chown -R www-data:www-data storage bootstrap/cache public
  chmod -R ug+rwx storage bootstrap/cache
  mkdir -p storage/psysh
  chown www-data:www-data storage/psysh
}

install_sudoers() {
  SRC="${APP_DIR}/sudoers.d/sark6api"
  DEST='/etc/sudoers.d/sarkapi'
  [ -f "${SRC}" ] || die "missing ${SRC}"

  info "Installing root-owned sudoers drop-in ${DEST}"
  # Do not symlink into the app tree — sudo rejects non-root ownership.
  if [ -L "${DEST}" ]; then
    info "Removing existing symlink ${DEST}"
    rm -f "${DEST}"
  fi
  install -o root -g root -m 0440 "${SRC}" "${DEST}"
  visudo -cf "${DEST}" >/dev/null
}

configure_apache() {
  info "Configuring Apache ports and sarkapi vhost"
  if [ ! -e /etc/apache2/installed_ports.conf ]; then
    cp /etc/apache2/ports.conf /etc/apache2/installed_ports.conf
  fi
  cp "${APP_DIR}/apache2/ports.conf" /etc/apache2/ports.conf

  if [ ! -e /etc/apache2/sites-available/sarkapi.conf ]; then
    ln -s "${APP_DIR}/apache2/sites-available/sarkapi.conf" \
      /etc/apache2/sites-available/sarkapi.conf
  fi
  a2ensite sarkapi >/dev/null
  apache2ctl configtest
  systemctl reload apache2
}

configure_shorewall() {
  if [ ! -f "${SHOREWALL_RULES}" ]; then
    info "Shorewall rules file ${SHOREWALL_RULES} not found — skip firewall step"
    return
  fi
  if grep -q "tcp ${API_PORT}" "${SHOREWALL_RULES}" 2>/dev/null; then
    info "Shorewall already allows TCP ${API_PORT}"
  else
    info "Adding Shorewall ACCEPT for TCP ${API_PORT}"
    printf '%s\n' "${SHOREWALL_RULE}" >> "${SHOREWALL_RULES}"
  fi
  if command -v shorewall >/dev/null 2>&1; then
    shorewall restart
  else
    info "shorewall command not found — rule written; restart Shorewall manually if needed"
  fi
}

smoke_hint() {
  HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  [ -n "${HOST_IP}" ] || HOST_IP='YOUR_PBX_FQDN_OR_IP'
  cat <<EOF

Install complete.

Smoke test:
  curl -k https://${HOST_IP}:${API_PORT}/up

Create the first API admin (see docs/installation.md §12):
  cd ${APP_DIR}
  sudo -u www-data env XDG_CONFIG_HOME=${APP_DIR}/storage/psysh \\
    php artisan tinker

On production boxes, replace snakeoil certs in apache2/sites-available/sarkapi.conf
with customer certs (see /etc/apache2/sites-available/sark-certs.conf).
EOF
}

main() {
  require_root
  resolve_app_dir
  check_sark
  install_os_packages
  install_composer
  install_php_deps
  configure_env
  link_database
  set_ownership
  install_sudoers
  configure_apache
  configure_shorewall
  smoke_hint
}

main "$@"
