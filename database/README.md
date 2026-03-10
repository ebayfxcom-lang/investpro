# Database Migrations

## Setup

1. Create a MySQL database named `investpro`
2. Run migrations in order:

```bash
mysql -u root -p investpro < migrations/001_create_tables.sql
mysql -u root -p investpro < migrations/002_seed_data.sql
```

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
| `custom_pages` | CMS custom pages |
| `exchange_rates` | Currency exchange rate pairs |
