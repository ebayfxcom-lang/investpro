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
mysql -u root -p investpro < database/migrations/004_feature_updates.sql
mysql -u root -p investpro < database/migrations/005_currencies_and_features.sql
mysql -u root -p investpro < database/migrations/006_new_features.sql
mysql -u root -p investpro < database/migrations/007_team_roles_notices_tickets_seo.sql
mysql -u root -p investpro < database/migrations/008_fix_withdrawal_memo_and_method_defaults.sql
mysql -u root -p investpro < database/migrations/009_ensure_all_tables.sql
mysql -u root -p investpro < database/migrations/010_fix_schema_gaps.sql
mysql -u root -p investpro < database/migrations/011_fix_registration_and_login.sql
mysql -u root -p investpro < database/migrations/012_keyword_moderation_and_features.sql
mysql -u root -p investpro < database/migrations/013_fixes_and_enhancements.sql
```

Default admin credentials (change immediately):
- Email: `admin@investpro.com`
- Password: `Admin@123456`

## Features

- **User panel**: Dashboard, Deposits, Withdrawals, Earnings, Referrals, Security, Settings, Spin & Earn, Rewards Hub, Community, KYC
- **Admin panel**: Full management of users, plans, deposits, withdrawals, transactions, earnings, currencies, exchange rates, spin rewards, blacklist, FAQ, news, settings, email templates, newsletter, performance, IP checks, SEO, community moderation, bots, rewards
- **Currency engine**: Auto price-sync for crypto (CoinGecko) and fiat (open.er-api), USD/EUR conversion snapshots on every transaction, price history tracking
- **Daily spin system**: Free daily spins, purchasable spins (from account balance), 12 configurable reward slots, server-side probability enforcement, complete history
- **Rewards hub**: Task-based eligibility (first deposit, referrals, deposits count, etc.), progress indicators, claim blocking until task is complete
- **Community**: User and admin posting, bot-driven activity, keyword moderation
- **Newsletter**: Audience filtering (all users, active users, guest subscribers, non-user subscribers, non-deposited users, plan-based)
- **Registration**: WhatsApp, Facebook, country, preferred currency, payout details, communication preferences
- **Email templates**: Transactional emails with account stats placeholders (balance, earnings, deposits, referrals, WhatsApp, etc.)
- **Security**: PDO prepared statements, Argon2id password hashing, CSRF protection, secure sessions, audit logs

## Cron Jobs

All cron tasks are run via `cron.php` using the CLI:

```bash
php /path/to/investpro/cron.php <task>
```

Available tasks:

| Task | Description |
|------|-------------|
| `earnings` | Process investment earnings for all active deposits |
| `expired` | Mark expired deposits and update investment statuses |
| `price_sync` | Sync crypto and fiat currency prices from external APIs |
| `bot_posts` | Run bot activity: post, like, and comment in community |

### Recommended crontab setup

```cron
# Process investment earnings (hourly)
0 * * * * php /path/to/investpro/cron.php earnings >> /path/to/investpro/storage/logs/cron.log 2>&1

# Process expired deposits (daily at midnight)
0 0 * * * php /path/to/investpro/cron.php expired >> /path/to/investpro/storage/logs/cron.log 2>&1

# Sync currency prices (every 15 minutes)
*/15 * * * * php /path/to/investpro/cron.php price_sync >> /path/to/investpro/storage/logs/cron.log 2>&1

# Run bot community activity (every 30 minutes)
*/30 * * * * php /path/to/investpro/cron.php bot_posts >> /path/to/investpro/storage/logs/cron.log 2>&1
```

### Bot posting setup

1. **Enable bots in admin panel**: Go to `/admin/community/bots` and create bot profiles with display names, tone categories, and post frequencies.
2. **Run the cron task**: The `bot_posts` cron task calls `BotService::run()` which:
   - Posts new content for bots that are due (based on `post_frequency` in minutes)
   - Likes recent team member posts (100% rate) and normal posts (~10% rate)
   - Comments on recent team member posts and normal posts (~20% rate)
3. **Verification**: After running `php cron.php bot_posts`, check `/admin/community` – new bot posts will appear with a `Bot` badge.
4. **Environment variables**: No additional environment variables are required for bot posting.

### Queue / worker

No queue worker is required. All background processing is handled synchronously via the cron script. For high-traffic environments, consider using a job queue (e.g., Redis + worker), but the default setup works without one.

## Directory Structure

```
investpro/
├── app/
│   ├── Controllers/        Admin and User controllers
│   ├── Core/               Router, Controller, Model, Auth, Session, Csrf, Database, etc.
│   ├── Models/             ORM-style models for each DB table
│   └── Services/           EmailService, CurrencyPriceService, ConversionService, SpinService,
│                           BotService, CronService, RewardEligibilityService, etc.
├── config/                 app.php, database.php, mail.php
├── cron.php                CLI entry point for background tasks
├── database/
│   └── migrations/         001–013 (run in order)
├── public/                 index.php, .htaccess (web root)
├── resources/
│   └── templates/          Smarty .tpl templates (admin/, user/, auth/, layouts/)
├── routes/
│   └── web.php             Route definitions
└── storage/
    ├── cache/              Smarty compile/cache
    └── logs/               Application and error logs
```

## Setup Notes

### Minimum crypto deposit
Set the `min_deposit` field on a deposit wallet in `/admin/deposit-wallets`. When a user selects that currency, the system validates the converted crypto amount meets the minimum before proceeding.

### Spin purchase from balance
Users purchase spins using their USD account balance at `/user/spin`. The balance is deducted atomically in a DB transaction. No double-deduction is possible.

### Newsletter audience filtering
When creating or sending a newsletter, select the recipient group:
- **All Users** – every registered user
- **Active Users Only** – users with `status = 'active'`
- **Guest Subscribers Only** – entries in `newsletter_guests` table
- **Subscribers Not in User System** – guest subscribers whose email is not a registered user
- **Users Without Deposits** – active users who have never deposited
- Optionally filter by **Active Plan Name** (e.g. "Gold Plan")
