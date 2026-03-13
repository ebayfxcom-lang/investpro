# Database Migrations

> **Requirements:** MySQL 8.0.45+, InnoDB, `utf8mb4` / `utf8mb4_unicode_ci`.

## Setup

1. Create a MySQL database named `investpro`
2. Run migrations in order:

```bash
mysql -u root -p investpro < migrations/001_create_tables.sql
mysql -u root -p investpro < migrations/002_seed_data.sql
mysql -u root -p investpro < migrations/003_extend_schema.sql
mysql -u root -p investpro < migrations/004_feature_updates.sql
mysql -u root -p investpro < migrations/005_currencies_and_features.sql
mysql -u root -p investpro < migrations/006_new_features.sql
mysql -u root -p investpro < migrations/007_team_roles_notices_tickets_seo.sql
mysql -u root -p investpro < migrations/008_fix_withdrawal_memo_and_method_defaults.sql
mysql -u root -p investpro < migrations/009_ensure_all_tables.sql
mysql -u root -p investpro < migrations/010_fix_schema_gaps.sql
```

> **Existing databases:** `CREATE TABLE IF NOT EXISTS` and `INSERT IGNORE`
> make every migration re-runnable for the table-creation and seed steps.
> Migrations 003–009 also include `ADD COLUMN IF NOT EXISTS` for column
> additions, but that clause is a MariaDB extension and **fails silently on
> MySQL 8.0**.  Migration **010** is the MySQL-only replacement that ensures
> all required columns exist using an `information_schema`-based stored
> procedure.  Always run migrations in order and include 010 when targeting
> MySQL 8.0.45.

## Default Admin Credentials

- **Email:** admin@investpro.com  
- **Password:** `Admin@123456`  
- ⚠️ **Change the admin password immediately after setup!**

## Tables Overview

| Table | Description |
|-------|-------------|
| `users` | Platform users and admins |
| `currencies` | Supported fiat and crypto currencies |
| `wallets` | User wallet balances per currency |
| `plans` | Investment plan definitions |
| `deposits` | User investment deposits |
| `withdrawals` | Withdrawal requests |
| `transactions` | All financial transactions ledger |
| `earnings` | ROI and bonus earnings records |
| `referral_earnings` | Referral commission records |
| `settings` | Site configuration key-value store |
| `blacklist` | Blocked IPs, emails, countries |
| `email_templates` | Editable email templates |
| `audit_logs` | Security and admin action audit trail |
| `news` | Platform news and announcements |
| `faq` | Frequently asked questions |
| `faq_categories` | FAQ category definitions |
| `custom_pages` | CMS custom pages |
| `exchange_rates` | Currency exchange rate pairs |
| `currency_price_history` | Historical crypto/fiat price snapshots |
| `exchange_rate_snapshots` | Per-transaction exchange rate records |
| `deposit_wallets` | Admin-managed crypto deposit addresses |
| `withdrawal_methods` | Admin-managed withdrawal methods |
| `kyc_submissions` | KYC document submissions |
| `spin_settings` | Lucky-spin wheel configuration |
| `spin_rewards` | Spin wheel prize slots |
| `user_spins` | Per-user spin credit balance |
| `spin_history` | Spin result history |
| `newsletters` | Newsletter campaigns |
| `newsletter_guests` | Guest newsletter subscribers |
| `scam_reports` | Public scam report submissions |
| `community_posts` | Community feed posts |
| `community_comments` | Community post comments |
| `community_likes` | Post like records |
| `bot_profiles` | Automated community bot profiles |
| `reward_offers` | Rewards Hub season offers |
| `reward_claims` | User reward claim records |
| `reward_progress` | Per-user progress towards a reward |
| `user_notices` | Admin-broadcast notices |
| `user_notice_reads` | Notice read/dismiss tracking |
| `ticket_departments` | Support ticket departments |
| `support_tickets` | Support tickets |
| `ticket_replies` | Ticket reply messages |
| `seo_pages` | Per-page SEO / Open Graph meta |
| `team_roles` | Staff role definitions |
| `permissions` | Permission definitions |
| `role_permissions` | Role ↔ permission assignments |
| `ip_checks` | IP-level access control records |
