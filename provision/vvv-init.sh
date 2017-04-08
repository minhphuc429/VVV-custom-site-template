#!/usr/bin/env bash
# Provision WordPress Stable

DOMAIN=`get_primary_host "${VVV_SITE_NAME}".dev`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}
# bash generate random 6 character alphanumeric string (lowercase only), ex: wp_lxdqpb_
PREFIX=wp_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)_
DB_PREFIX=`get_config_value 'db_prefix' "${PREFIX}"`
LOCALE=`get_config_value 'locale' "en_US"`
#define array of plugin slugs to install
PLUGINS="akismet all-in-one-seo-pack contact-form-7 flamingo jetpack stops-core-theme-and-plugin-updates sucuri-scanner tesla-login-customizer tinymce-advanced w3-total-cache woocommerce wordpress-importer wordpress-seo wp-smushit wp-super-cache yith-woocommerce-ajax-navigation yith-woocommerce-compare yith-woocommerce-quick-view yith-woocommerce-wishlist remove-query-strings-from-static-resources"
PLUGINS=( `get_config_value 'plugins' "${PLUGINS}"` )

# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-load.php" ]]; then
    echo "Downloading WordPress..."
	noroot wp core download --locale="${LOCALE}" --version="${WP_VERSION}"
fi

if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-config.php" ]]; then
  echo "Configuring WordPress Stable..."
  noroot wp core config --dbname="${DB_NAME}" --dbuser=wp --dbpass=wp --dbprefix="${DB_PREFIX}" --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP
fi

if ! $(noroot wp core is-installed); then
  echo "Installing WordPress Stable..."

  if [ "${WP_TYPE}" = "subdomain" ]; then
    INSTALL_COMMAND="multisite-install --subdomains"
  elif [ "${WP_TYPE}" = "subdirectory" ]; then
    INSTALL_COMMAND="multisite-install"
  else
    INSTALL_COMMAND="install"
  fi

  noroot wp core ${INSTALL_COMMAND} --url="${DOMAIN}" --quiet --title="${SITE_TITLE}" --admin_user=developer --admin_password="developer" --admin_email="developer@vvv.dev" --skip-email
  
  noroot wp core language update

  echo "Deleting post hello world"
  noroot wp post delete 1 --force --defer-term-counting --quiet

  echo "Deleting page example"
  noroot wp post delete 2 --force --defer-term-counting --quiet

  echo "Deleting plugin Hello Dolly"
  noroot wp plugin delete hello --quiet

  #loop through array, install and activate the plugin, ${PLUGINS[@]}
  echo "Installing plugin"
  for PLUGIN in "${PLUGINS[@]}"; do
  #check if plugin is installed, sets exit status to 1 if not found
    noroot wp plugin is-installed $PLUGIN

  #install plugin if not present based on exit code value
    if [ $? -eq 1 ]; then
        noroot wp plugin install $PLUGIN --quiet
    fi
  done

else
  echo "Updating WordPress Stable..."
  cd ${VVV_PATH_TO_SITE}/public_html
  noroot wp core update --version="${WP_VERSION}"
fi

cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
sed -i "s#{{DOMAINS_HERE}}#${DOMAINS}#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
