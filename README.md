# InvestPro – PHP 8.3 Investment Platform

A professional, production-ready investment platform built with native PHP 8.3, Smarty 5 templates, Composer autoloading, and MySQL/MariaDB.

## Requirements

- PHP 8.3+
- MySQL 8.0+ or MariaDB 10.6+
- Composer
- Web server (Apache with mod_rewrite or Nginx)

## Quick Start

```bash
composer install
cp .env.example .env   # Edit with your DB/mail settings
```

Import migrations in order:
```bash
mysql -u root -p investpro < database/migrations/001_create_tables.sql
mysql -u root -p investpro < database/migrations/002_seed_data.sql
mysql -u root -p investpro < database/migrations/003_extend_schema.sql
```

Default admin credentials (change immediately):
- Email: `admin@investpro.com`
- Password: `Admin@123456`

## Features

- **User panel**: Dashboard, Deposits, Withdrawals, Earnings, Referrals, Security, Settings, Spin & Earn
- **Admin panel**: Full management of users, plans, deposits, withdrawals, transactions, earnings, currencies, exchange rates, spin rewards, blacklist, FAQ, news, settings, email templates, newsletter, performance, IP checks
- **Currency engine**: Auto price-sync for crypto (CoinGecko) and fiat (open.er-api), USD/EUR conversion snapshots on every transaction, price history tracking
- **Daily spin system**: Free daily spins, purchasable spins, 12 configurable reward slots, server-side probability enforcement, complete history
- **Registration**: WhatsApp, Facebook, country, preferred currency, payout details, communication preferences
- **Email templates**: Transactional emails with account stats placeholders (balance, earnings, deposits, referrals, WhatsApp, etc.)
- **Security**: PDO prepared statements, Argon2id password hashing, CSRF protection, secure sessions, audit logs

## Cron Jobs

```cron
# Process investment earnings (run hourly or daily)
0 * * * * php /path/to/investpro/cron.php earnings

# Process expired deposits (run daily)
0 0 * * * php /path/to/investpro/cron.php expired

# Sync currency prices (run every 15 minutes)
*/15 * * * * php /path/to/investpro/cron.php price_sync
```

## Directory Structure

```
investpro/
├── app/
│   ├── Controllers/        Admin and User controllers
│   ├── Core/               Router, Controller, Model, Auth, Session, Csrf, etc.
│   ├── Models/             ORM-style models for each DB table
│   └── Services/           EmailService, CurrencyPriceService, ConversionService, SpinService, etc.
├── config/                 app.php, database.php, mail.php
├── database/
│   └── migrations/         001_create_tables, 002_seed_data, 003_extend_schema
├── public/                 index.php, .htaccess (web root)
├── resources/
│   └── templates/          Smarty .tpl templates (admin/, user/, auth/, layouts/)
├── routes/
│   └── web.php             Route definitions
└── storage/
    ├── cache/              Smarty compile/cache
    └── logs/               Application and error logs
```
