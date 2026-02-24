# Maruti Engineers WordPress Setup (No Docker Required)

You said you do not have Docker locally, so this setup is now focused on **XAMPP/WAMP/LAMP** style localhost WordPress.

## Quick answer: how you will access the site without Docker
You can run WordPress directly from your local Apache + MySQL stack.

Typical URL after setup:
- `http://localhost/maruti_engineers`
- Admin: `http://localhost/maruti_engineers/wp-admin`

---

## 1) Prerequisites (install once)
Install any one local stack:
- **Windows:** XAMPP or WAMP
- **macOS:** MAMP or Laravel Valet + MySQL
- **Linux:** Apache + PHP + MySQL/MariaDB

Also ensure these commands are available in terminal:
- `php`
- `mysql`
- `curl`

> If using XAMPP, start **Apache** and **MySQL** from XAMPP Control Panel first.

---

## 2) Configure environment
```bash
cp .env.local.example .env.local
```

Update `.env.local` as needed:
- `WP_SITE_URL` should match your localhost folder URL
- DB credentials should match your local MySQL

---

## 3) Auto install WordPress + free theme
```bash
./scripts/setup-wordpress-local.sh
```

This script will:
1. Download WP-CLI (if missing)
2. Download WordPress core
3. Create DB (if not exists)
4. Generate `wp-config.php`
5. Install WordPress
6. Install and activate **Astra** (free theme)

---

## 4) Place project in web root (important)
For localhost URL to work, keep this repository in your web root folder:
- **XAMPP:** `htdocs/maruti_engineers`
- **WAMP:** `www/maruti_engineers`

Then access:
- Site: `http://localhost/maruti_engineers`
- Admin: `http://localhost/maruti_engineers/wp-admin`

---

## Database connection details
From `.env.local`:
- Host: `WP_DB_HOST` (`127.0.0.1` by default)
- Port: `WP_DB_PORT` (`3306`)
- DB name: `WP_DB_NAME`
- User: `WP_DB_USER`
- Password: `WP_DB_PASSWORD`

WordPress stores these values in `wordpress/wp-config.php`.

---

## Content workflow (what to edit)
After login (`/wp-admin`):
- **Pages** → Create/Edit: Home, About, Our Work, Contact
- **Posts** → Project updates/news
- **Appearance** → Customize theme
- **Plugins** → Add contact form, SEO, gallery later

---

## Optional Docker path (if you install Docker later)
You can still use the existing `docker-compose.yml` and `.env.example` flow if needed.
