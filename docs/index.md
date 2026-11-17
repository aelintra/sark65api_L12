# Introduction
## Background
sark65 api is a fairly vanilla OAS JSON API. It allows you to programmatically do anything you can do manually at the SARK V6 browser. <br/>

Using the API you may...

* Create custom extensions and new features. 
* Rewrite all or parts of the SARK browser to create a package of your own. 
* Control a remote Asterisk from your app. 
* Control a remote SARK from a management layer.
* Create an interface to a third party software package. 

All of these things are possible with the API.

## Requirements
sark65api requires a **SARK V65** instance on **Ubuntu 24.04** (64-bit x86 or ARM) running PHP 8.2 or later. The API uses the Laravel 12 framework. The support code is written in a mix of standalone PHP, bash and C code.

For a full install onto a SARK box, see [Installation](installation.md).