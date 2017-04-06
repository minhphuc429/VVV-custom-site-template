# VVV Custom site template
For when you just need a simple dev site

## Overview
This template will allow you to create a WordPress dev environment using only `vvv-config.yml`.

The supported environments are:
- A single site
- A subdomain multisite
- A subdirectory multisite

# Configuration

### The minimum required configuration:

```
my-site:
  repo: https://github.com/minhphuc429/VVV-custom-site-template.git
  hosts:
    - my-site.dev
```
| Setting    | Value       |
|------------|-------------|
| Domain     | my-site.dev |
| Site Title | my-site.dev |
| DB Name    | my-site     |
| Site Type  | Single      |
| WP Version | Latest      |

### Minimal configuration with custom domain and WordPress Nightly:

```
my-site:
  repo: https://github.com/minhphuc429/VVV-custom-site-template.git
  hosts:
    - foo.dev
  custom:
    wp_version: nightly
```
| Setting    | Value       |
|------------|-------------|
| Domain     | foo.dev     |
| Site Title | foo.dev     |
| DB Name    | my-site     |
| Site Type  | Single      |
| WP Version | Nightly     |

### WordPress Multisite with Subdomains:

```
my-site:
  repo: https://github.com/minhphuc429/VVV-custom-site-template.git
  hosts:
    - multisite.dev
    - site1.multisite.dev
    - site2.multisite.dev
  custom:
    wp_type: subdomain
```
| Setting    | Value               |
|------------|---------------------|
| Domain     | multisite.dev       |
| Site Title | multisite.dev       |
| DB Name    | my-site             |
| Site Type  | Subdomain Multisite |
| WP Version | Nightly             |

## Configuration Options

```
hosts:
    - foo.dev
    - bar.dev
    - baz.dev
```
Defines the domains and hosts for VVV to listen on. 
The first domain in this list is your sites primary domain.

```
custom:
    site_title: Local Wordpress Dev
```
Defines the site title to be set upon installing WordPress.

```
custom:
    wp_version: 4.7.3
```
Defines the WordPress version you wish to install.
Valid values are:
- nightly
- latest
- a version number

Older versions of WordPress will not run on PHP7, see this page on how to change PHP version per site. // TODO: Add link.

```
custom:
    wp_type: single
```
Defines the type of install you are creating.
Valid values are:
- single
- subdomain
- subdirectory

Defines the DB name for the installation.
```
custom:
    db_name: local_wordpress_dev
```

Defines the DB prefix for the installation.
```
custom:
    db_prefix: bjk2h1_
```

Defines the language you want to download for the installation.
```
custom:
    locale: vi
```

Batch Install WordPress Plugins.
```
custom:
    plugins: wordpress-seo ewww-image-optimizer better-wp-security aceide
```