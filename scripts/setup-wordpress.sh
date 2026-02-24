#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "Missing .env file. Create it first with: cp .env.example .env"
  exit 1
fi

set -a
source ./.env
set +a

echo "Starting WordPress + DB containers..."
docker compose up -d

echo "Waiting for WordPress container to become ready..."
until docker compose exec -T wordpress bash -lc "php -v >/dev/null 2>&1"; do
  sleep 3
done

echo "Installing WordPress core (if not already installed)..."
docker compose exec -T wordpress bash -lc '
  if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install \
      --url="'"${WP_SITE_URL}"'" \
      --title="'"${WP_SITE_TITLE}"'" \
      --admin_user="'"${WP_ADMIN_USER}"'" \
      --admin_password="'"${WP_ADMIN_PASSWORD}"'" \
      --admin_email="'"${WP_ADMIN_EMAIL}"'" \
      --skip-email \
      --allow-root
  else
    echo "WordPress already installed; skipping core install."
  fi
'

echo "Installing and activating free Astra theme..."
docker compose exec -T wordpress bash -lc '
  wp theme install astra --activate --allow-root
'

echo "Done."
echo "WordPress:  ${WP_SITE_URL}"
echo "Admin:      ${WP_SITE_URL}/wp-admin"
echo "phpMyAdmin: http://localhost:8081"
