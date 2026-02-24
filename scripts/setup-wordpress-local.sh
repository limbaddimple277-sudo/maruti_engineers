#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env.local ]]; then
  echo "Missing .env.local file. Create it first with: cp .env.local.example .env.local"
  exit 1
fi

set -a
source ./.env.local
set +a

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

require_cmd php
require_cmd mysql
require_cmd curl
require_cmd tar

PROJECT_DIR="${WP_PROJECT_DIR:-wordpress}"
WP_PATH="$(pwd)/${PROJECT_DIR}"
WP_CLI="$(pwd)/wp-cli.phar"

if [[ ! -f "$WP_CLI" ]]; then
  echo "Downloading WP-CLI..."
  curl -fsSL -o "$WP_CLI" https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
fi

chmod +x "$WP_CLI"

if [[ ! -d "$WP_PATH" ]]; then
  echo "Downloading WordPress core into ${WP_PATH} ..."
  php "$WP_CLI" core download --path="$WP_PATH" --allow-root
fi

MYSQL_AUTH_ARGS=("-u${MYSQL_ROOT_USER}")
if [[ -n "${MYSQL_ROOT_PASSWORD}" ]]; then
  MYSQL_AUTH_ARGS+=("-p${MYSQL_ROOT_PASSWORD}")
fi

DB_HOST_WITH_PORT="${WP_DB_HOST}:${WP_DB_PORT}"

echo "Creating database if it does not exist..."
mysql -h "${WP_DB_HOST}" -P "${WP_DB_PORT}" "${MYSQL_AUTH_ARGS[@]}" -e "CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\`;"

if [[ ! -f "$WP_PATH/wp-config.php" ]]; then
  echo "Generating wp-config.php ..."
  php "$WP_CLI" config create \
    --path="$WP_PATH" \
    --dbname="$WP_DB_NAME" \
    --dbuser="$WP_DB_USER" \
    --dbpass="$WP_DB_PASSWORD" \
    --dbhost="$DB_HOST_WITH_PORT" \
    --skip-check \
    --allow-root
fi

echo "Installing WordPress core (if not installed)..."
if ! php "$WP_CLI" core is-installed --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
  php "$WP_CLI" core install \
    --path="$WP_PATH" \
    --url="$WP_SITE_URL" \
    --title="$WP_SITE_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root
else
  echo "WordPress already installed; skipping core install."
fi

echo "Installing and activating free Astra theme..."
php "$WP_CLI" theme install astra --activate --path="$WP_PATH" --allow-root

echo
cat <<MSG
✅ Local WordPress setup complete.

Next step to access site:
1) Put this repo inside your web server document root, e.g.:
   - XAMPP: htdocs/maruti_engineers
   - WAMP: www/maruti_engineers
2) Open: ${WP_SITE_URL}
3) Admin: ${WP_SITE_URL}/wp-admin

If WP_SITE_URL doesn't match your folder path, update .env.local and re-run.
MSG
