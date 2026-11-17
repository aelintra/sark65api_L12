# Installation

This guide installs **sark65api_L12** (Laravel 12) onto an existing **SARK V65** PBX so the API can share the live SARK database and system tools.

Prefer the packaged installer when possible. Clone the tree under `/opt`, then run as root:

```sh
cd /opt
git clone https://github.com/aelintra/sark65api_L12.git sark65api_L12
cd /opt/sark65api_L12
./sarkapi_installer.sh
```

The script (`sarkapi_installer.sh`) performs the steps below (packages, Composer, `.env`, DB symlink, ownership, **root-owned** sudoers copy, Apache on **44300**, Shorewall). First API admin creation is still manual (see §12). Use this guide to understand or run the steps by hand.

## System requirements

| Requirement | Detail |
|-------------|--------|
| Host OS | **Ubuntu 24.04 LTS** (64-bit only; x86_64 or ARM64) |
| PBX | **SARK V65** already installed and working (`/opt/sark` present) |
| PHP | **8.2+** (as provided by the SARK V65 stack) |
| Web server | **Apache 2** with `mod_ssl` and `mod_rewrite` |
| Privileges | Root / `sudo` on the PBX |
| Network | HTTPS API listens on port **44300** (open in Shorewall if needed) |
| Framework | Laravel **12**, Sanctum token auth |

Also required at install time:

* `git` (to clone the repo) or another way to place the tree under `/opt`
* `composer` (installed in the steps below if missing)
* PHP extension **zip** (`php-zip`)
* Write access to `/opt`, `/etc/apache2`, and `/etc/sudoers.d`

**Do not** install this API onto a general-purpose Ubuntu box that is not already a SARK V65 appliance.

## What the install does

1. Places the application at `/opt/sark65api_L12`
2. Installs PHP Composer dependencies
3. Creates `.env`, generates `APP_KEY`
4. Points Laravel’s sqlite file at the live SARK DB (`/opt/sark/db/sark.db`)
5. Sets ownership for the Apache user (`www-data`)
6. Enables the Apache vhost on port **44300** and sudoers helpers used by backups / firewall / PBX control

## Install directory

All paths below assume:

```text
/opt/sark65api_L12
```

If you install elsewhere, update `DocumentRoot`, `<Directory>`, and `open_basedir` in `apache2/sites-available/sarkapi.conf` to match.

---

## Step-by-step

### 1. Confirm SARK V65 is present

```sh
ls /opt/sark
ls /opt/sark/db/sark.db
php -v
apache2ctl -v
```

You should see PHP **≥ 8.2** and the SARK tree. If `/opt/sark` is missing, install SARK V65 first, then return here.

### 2. Install OS packages

```sh
sudo apt update
sudo apt install -y git php-zip unzip
```

Enable Apache modules if they are not already on (typical on a SARK box):

```sh
sudo a2enmod ssl rewrite headers
```

### 3. Clone the API into `/opt`

```sh
cd /opt
sudo git clone https://github.com/aelintra/sark65api_L12.git sark65api_L12
cd /opt/sark65api_L12
```

If the host cannot reach GitHub, copy a release tarball or sync the tree from another machine into `/opt/sark65api_L12` instead, then `cd` there.

### 4. Install Composer (if needed)

```sh
if ! command -v composer >/dev/null 2>&1; then
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  php -r "unlink('composer-setup.php');"
fi
composer --version
```

### 5. Install PHP dependencies

SARK V65 ships PHP **8.3**. This repo pins Composer’s platform to `8.3.6` so lockfile resolution stays compatible (do not resolve deps on PHP 8.4 without that pin — Symfony 8 components will fail on the PBX).

From `/opt/sark65api_L12`:

```sh
cd /opt/sark65api_L12
composer install --no-dev --optimize-autoloader
```

Use a normal `composer install` only if you need dev tools on the PBX.

### 6. Create `.env` and application key

```sh
cd /opt/sark65api_L12
cp .env.example .env
```

Edit `.env` for a SARK appliance. At minimum set:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://YOUR_PBX_FQDN_OR_IP:44300

DB_CONNECTION=sqlite

# Prefer file/sync drivers on the appliance so Laravel does not
# create session/cache/queue tables inside the live SARK database.
SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
```

Then generate the key:

```sh
php artisan key:generate
```

### 7. Link the SARK database

Laravel expects `database/database.sqlite`. On SARK this must be the live PBX database:

```sh
cd /opt/sark65api_L12/database
sudo rm -f database.sqlite
sudo ln -s /opt/sark/db/sark.db database.sqlite
ls -l database.sqlite
```

**Important:** do **not** run a full `php artisan migrate` against this symlink unless you know exactly which tables are safe to add. The API shares SARK’s sqlite file. Sanctum needs a `personal_access_tokens` table (and a compatible `users` table); confirm those exist in `/opt/sark/db/sark.db` before issuing tokens. If they are missing, apply only the Sanctum / users migrations after backup — never migrate blindly on a production PBX.

### 8. Set ownership and permissions

```sh
sudo chown -R www-data:www-data /opt/sark65api_L12/storage
sudo chown -R www-data:www-data /opt/sark65api_L12/bootstrap/cache
sudo chown -R www-data:www-data /opt/sark65api_L12/public
sudo chmod -R ug+rwx /opt/sark65api_L12/storage /opt/sark65api_L12/bootstrap/cache
```

### 9. Install sudoers drop-in

The API runs some privileged actions (Shorewall, Asterisk start/stop, reboot, LDAP restart helpers) via `sudo` as `www-data`.

Install a **root-owned copy** (do not symlink into the app tree — sudoers rejects non-root ownership):

```sh
sudo install -o root -g root -m 0440 \
  /opt/sark65api_L12/sudoers.d/sark6api /etc/sudoers.d/sarkapi
sudo visudo -cf /etc/sudoers.d/sarkapi
```

### 10. Configure Apache ports and site

Backup the stock ports file once, then install the API ports config (adds listen on **44300**):

```sh
if [ ! -e /etc/apache2/installed_ports.conf ]; then
  sudo cp /etc/apache2/ports.conf /etc/apache2/installed_ports.conf
fi
sudo cp /opt/sark65api_L12/apache2/ports.conf /etc/apache2/ports.conf
```

Link and enable the vhost:

```sh
if [ ! -e /etc/apache2/sites-available/sarkapi.conf ]; then
  sudo ln -s /opt/sark65api_L12/apache2/sites-available/sarkapi.conf \
    /etc/apache2/sites-available/sarkapi.conf
fi
sudo a2ensite sarkapi
sudo apache2ctl configtest
sudo systemctl reload apache2
```

The bundled vhost serves `DocumentRoot /opt/sark65api_L12/public` over HTTPS on port **44300**. It includes snakeoil SSL paths suitable for lab boxes:

```apache
SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
```

On production SARK hosts, point those directives at the customer certs (see `/etc/apache2/sites-available/sark-certs.conf`) before exposing the API externally.

### 11. Firewall

If Shorewall is in use (normal on SARK), allow TCP **44300**, then restart Shorewall. Example for `/etc/shorewall/sark_rules`:

```text
ACCEPT net $FW tcp 44300 - - # sark65 API
```

```sh
sudo shorewall restart
```

### 12. Set a starter admin password (first Sanctum user)

There is **no default Sanctum login**. The installer does not create an API user or password. Until you add one, only `POST /api/auth/login` is reachable unauthenticated, and it will fail without a valid account.

`/api/auth/register` can only be called by an **existing** admin, so the **first** API admin must be created on the PBX with Artisan. Login password rules for the API are `alpha_dash` (letters, numbers, dashes, underscores — see [Authentication](auth.md)).

#### One-shot create (recommended)

On the PBX, replace the email and password, then run:

```sh
cd /opt/sark65api_L12
sudo mkdir -p storage/psysh
sudo chown www-data:www-data storage/psysh

sudo -u www-data env XDG_CONFIG_HOME=/opt/sark65api_L12/storage/psysh \
  php artisan tinker --execute="
\App\Models\User::create([
    'name' => 'apiadmin',
    'email' => 'apiadmin@example.com',
    'password' => 'ChooseA_Strong-Password',
    'role' => 'isAdmin',
]);
"
```

(`www-data` cannot write PsySH’s default config under `/var/www`; `XDG_CONFIG_HOME` must point at `storage/psysh`.)

The `password` attribute is hashed automatically by the User model.

#### Interactive tinker (same result)

```sh
cd /opt/sark65api_L12
sudo -u www-data env XDG_CONFIG_HOME=/opt/sark65api_L12/storage/psysh \
  php artisan tinker
```

```php
\App\Models\User::create([
    'name' => 'apiadmin',
    'email' => 'apiadmin@example.com',
    'password' => 'ChooseA_Strong-Password',
    'role' => 'isAdmin',
]);
```

Exit with `exit`.

#### Reset password on an existing API user

```php
$u = \App\Models\User::where('email', 'apiadmin@example.com')->first();
$u->password = 'ChooseA_Strong-Password';
$u->role = 'isAdmin';
$u->save();
```

#### Prove login

```sh
curl -k -X POST https://YOUR_PBX_FQDN_OR_IP:44300/api/auth/login \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"email":"apiadmin@example.com","password":"ChooseA_Strong-Password"}'
```

The JSON response includes **`accessToken`** (not `token`). Use it as `Authorization: Bearer …` on later calls.

After the first admin exists, further users can be created with `POST /api/auth/register` (see [Authentication](auth.md)) using that admin’s bearer token.

### 13. Smoke test

From another host (or locally):

```sh
curl -k https://YOUR_PBX_FQDN_OR_IP:44300/up
```

Laravel’s health route should respond successfully.

Log in and capture the token:

```sh
curl -k -X POST https://YOUR_PBX_FQDN_OR_IP:44300/api/auth/login \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"email":"admin@example.com","password":"ChooseAStrongPassword"}'
```

The JSON response includes `accessToken`. Use it as a Bearer token, for example:

```sh
TOKEN='paste-accessToken-here'

curl -k https://YOUR_PBX_FQDN_OR_IP:44300/api/auth/whoami \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/json'
```

---

## Post-install checklist

* [ ] `/opt/sark65api_L12` owned appropriately; `storage` and `bootstrap/cache` writable by `www-data`
* [ ] `database/database.sqlite` → `/opt/sark/db/sark.db`
* [ ] `.env` has `APP_KEY`, `APP_DEBUG=false`, and file/sync drivers for session/cache/queue
* [ ] Apache site `sarkapi` enabled; port **44300** listening
* [ ] `/etc/sudoers.d/sarkapi` present and valid
* [ ] Starter Sanctum admin created (§12) and `/api/auth/login` returns `accessToken`
* [ ] `/up` returns success

## Upgrading an existing install

```sh
cd /opt/sark65api_L12
sudo -u www-data git pull   # or sync the new tree
composer install --no-dev --optimize-autoloader
php artisan config:clear
php artisan route:clear
sudo systemctl reload apache2
```

Keep your existing `.env` and the `database.sqlite` symlink. Review release notes before upgrading across major Laravel versions.

## Related docs

* [Introduction](index.md) — product overview
* [Authentication](auth.md) — tokens and login
* [Overview](api.md) — request conventions
* [API Digest](general.md) — endpoint reference
