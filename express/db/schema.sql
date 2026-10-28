-- Shahed Store MySQL schema (generated from the live database). Run once in Hostinger phpMyAdmin.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS app_users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  email VARCHAR(191) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NULL,
  reset_token_hash VARCHAR(128) NULL,
  reset_expires DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `abandoned_checkouts` (
  `id` CHAR(36) NOT NULL,
  `session_token` LONGTEXT NOT NULL,
  `user_id` CHAR(36) NULL,
  `customer_name` LONGTEXT NULL,
  `customer_email` LONGTEXT NULL,
  `customer_phone` LONGTEXT NULL,
  `cart_items` JSON NOT NULL,
  `item_count` INT NOT NULL DEFAULT 0,
  `subtotal` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `discount_amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `total` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `coupon_code` LONGTEXT NULL,
  `payment_method` LONGTEXT NULL,
  `notes` LONGTEXT NULL,
  `page_url` LONGTEXT NULL,
  `user_agent` LONGTEXT NULL,
  `converted` TINYINT(1) NOT NULL DEFAULT 0,
  `converted_order_id` CHAR(36) NULL,
  `converted_at` DATETIME(3) NULL,
  `contacted` TINYINT(1) NOT NULL DEFAULT 0,
  `contacted_at` DATETIME(3) NULL,
  `admin_notes` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `addresses` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `label` LONGTEXT NOT NULL,
  `recipient_name` LONGTEXT NOT NULL,
  `phone` LONGTEXT NOT NULL,
  `address_line` LONGTEXT NOT NULL,
  `city` LONGTEXT NOT NULL,
  `district` LONGTEXT NULL,
  `postal_code` LONGTEXT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_2fa` (
  `user_id` CHAR(36) NOT NULL,
  `secret` LONGTEXT NOT NULL,
  `enabled` TINYINT(1) NOT NULL DEFAULT 0,
  `backup_codes` JSON NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `verified_at` DATETIME(3) NULL,
  `last_used_at` DATETIME(3) NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_2fa_config` (
  `id` INT NOT NULL DEFAULT 1,
  `session_ttl_hours` INT NOT NULL DEFAULT 12,
  `remember_device_ttl_days` INT NOT NULL DEFAULT 30,
  `allow_remember_device` TINYINT(1) NOT NULL DEFAULT 1,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `system_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_2fa_sessions` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `token` LONGTEXT NOT NULL,
  `user_agent` LONGTEXT NULL,
  `ip` LONGTEXT NULL,
  `expires_at` DATETIME(3) NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_email_otps` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `code_hash` LONGTEXT NOT NULL,
  `expires_at` DATETIME(3) NOT NULL,
  `used_at` DATETIME(3) NULL,
  `attempts` INT NOT NULL DEFAULT 0,
  `ip` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_accounts` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `referral_code` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `custom_commission_percent` DECIMAL(20,6) NULL,
  `custom_customer_discount_percent` DECIMAL(20,6) NULL,
  `total_clicks` INT NOT NULL DEFAULT 0,
  `total_conversions` INT NOT NULL DEFAULT 0,
  `total_earned` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `total_paid` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `available_balance` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `payout_method` LONGTEXT NULL,
  `payout_account` LONGTEXT NULL,
  `payout_account_name` LONGTEXT NULL,
  `application_note` LONGTEXT NULL,
  `admin_note` LONGTEXT NULL,
  `approved_at` DATETIME(3) NULL,
  `approved_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `applicant_name` LONGTEXT NULL,
  `applicant_email` LONGTEXT NULL,
  `applicant_phone` LONGTEXT NULL,
  `website_url` LONGTEXT NULL,
  `facebook_url` LONGTEXT NULL,
  `youtube_url` LONGTEXT NULL,
  `other_social_url` LONGTEXT NULL,
  `audience_size` LONGTEXT NULL,
  `niche` LONGTEXT NULL,
  `why_join` LONGTEXT NULL,
  `promotion_strategy` LONGTEXT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_clicks` (
  `id` CHAR(36) NOT NULL,
  `affiliate_id` CHAR(36) NOT NULL,
  `referral_code` LONGTEXT NOT NULL,
  `visitor_id` LONGTEXT NULL,
  `product_id` CHAR(36) NULL,
  `landing_page` LONGTEXT NULL,
  `ip_address` LONGTEXT NULL,
  `user_agent` LONGTEXT NULL,
  `referrer` LONGTEXT NULL,
  `country` LONGTEXT NULL,
  `converted` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_conversions` (
  `id` CHAR(36) NOT NULL,
  `affiliate_id` CHAR(36) NOT NULL,
  `order_id` CHAR(36) NOT NULL,
  `order_number` LONGTEXT NOT NULL,
  `order_total` DECIMAL(20,6) NOT NULL,
  `commission_percent` DECIMAL(20,6) NOT NULL,
  `commission_amount` DECIMAL(20,6) NOT NULL,
  `customer_discount_amount` DECIMAL(20,6) NULL DEFAULT 0,
  `status` LONGTEXT NOT NULL,
  `paid_at` DATETIME(3) NULL,
  `rejection_reason` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_product_commissions` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `commission_percent` DECIMAL(20,6) NOT NULL,
  `customer_discount_percent` DECIMAL(20,6) NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_settings` (
  `id` INT NOT NULL DEFAULT 1,
  `is_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `default_commission_percent` DECIMAL(20,6) NOT NULL DEFAULT 10,
  `customer_discount_percent` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `enable_customer_discount` TINYINT(1) NOT NULL DEFAULT 0,
  `enable_affiliate_commission` TINYINT(1) NOT NULL DEFAULT 1,
  `minimum_withdrawal` DECIMAL(20,6) NOT NULL DEFAULT 500,
  `cookie_duration_days` INT NOT NULL DEFAULT 30,
  `auto_approve_applications` TINYINT(1) NOT NULL DEFAULT 0,
  `terms_and_conditions` LONGTEXT NULL,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `affiliate_withdrawals` (
  `id` CHAR(36) NOT NULL,
  `affiliate_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `amount` DECIMAL(20,6) NOT NULL,
  `method` LONGTEXT NOT NULL,
  `account_number` LONGTEXT NOT NULL,
  `account_name` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `admin_notes` LONGTEXT NULL,
  `transaction_id` LONGTEXT NULL,
  `requested_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `processed_at` DATETIME(3) NULL,
  `processed_by` CHAR(36) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `backup_history` (
  `id` CHAR(36) NOT NULL,
  `action` LONGTEXT NOT NULL,
  `label` LONGTEXT NOT NULL,
  `tables` JSON NOT NULL,
  `records` INT NOT NULL DEFAULT 0,
  `files` INT NOT NULL DEFAULT 0,
  `status` LONGTEXT NOT NULL,
  `error` LONGTEXT NULL,
  `note` LONGTEXT NULL,
  `snapshot` JSON NULL,
  `snapshot_rows` INT NOT NULL DEFAULT 0,
  `reverted_at` DATETIME(3) NULL,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `backup_sync_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `kind` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `details` JSON NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `backup_sync_queue` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `table_name` LONGTEXT NOT NULL,
  `pk_text` LONGTEXT NOT NULL,
  `op` LONGTEXT NOT NULL,
  `row_data` JSON NULL,
  `attempts` INT NOT NULL DEFAULT 0,
  `last_error` LONGTEXT NULL,
  `next_retry_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `backup_sync_state` (
  `key` VARCHAR(191) NOT NULL,
  `value` JSON NOT NULL,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bkash_transactions` (
  `id` CHAR(36) NOT NULL,
  `payment_id` LONGTEXT NULL,
  `trx_id` LONGTEXT NULL,
  `order_id` CHAR(36) NULL,
  `order_number` LONGTEXT NULL,
  `user_id` CHAR(36) NULL,
  `customer_name` LONGTEXT NULL,
  `customer_email` LONGTEXT NULL,
  `customer_phone` LONGTEXT NULL,
  `payer_msisdn` LONGTEXT NULL,
  `payer_reference` LONGTEXT NULL,
  `amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `currency` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `mode` LONGTEXT NOT NULL,
  `status_code` LONGTEXT NULL,
  `status_message` LONGTEXT NULL,
  `raw_create` JSON NULL,
  `raw_execute` JSON NULL,
  `paid_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `purpose` LONGTEXT NOT NULL,
  `topup_request_id` CHAR(36) NULL,
  `trx_id_enc` LONGBLOB NULL,
  `payer_reference_enc` LONGBLOB NULL,
  `payer_msisdn_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_categories` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `color` LONGTEXT NULL,
  `sort_order` INT NULL DEFAULT 0,
  `is_active` TINYINT(1) NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_comments` (
  `id` CHAR(36) NOT NULL,
  `post_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NULL,
  `author_name` LONGTEXT NOT NULL,
  `author_email` LONGTEXT NULL,
  `content` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `parent_id` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_post_tags` (
  `post_id` CHAR(36) NOT NULL,
  `tag_id` CHAR(36) NOT NULL,
  PRIMARY KEY (`post_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_posts` (
  `id` CHAR(36) NOT NULL,
  `title` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `excerpt` LONGTEXT NULL,
  `content` LONGTEXT NULL,
  `featured_image` LONGTEXT NULL,
  `category_id` CHAR(36) NULL,
  `author_name` LONGTEXT NULL,
  `author_avatar` LONGTEXT NULL,
  `author_bio` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `is_featured` TINYINT(1) NULL DEFAULT 0,
  `tags` JSON NULL,
  `reading_time` INT NULL DEFAULT 5,
  `views` INT NULL DEFAULT 0,
  `seo_title` LONGTEXT NULL,
  `seo_description` LONGTEXT NULL,
  `published_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_tags` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `categories` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `image_url` LONGTEXT NULL,
  `parent_id` CHAR(36) NULL,
  `is_active` TINYINT(1) NULL DEFAULT 1,
  `sort_order` INT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `chat_conversations` (
  `id` CHAR(36) NOT NULL,
  `session_id` LONGTEXT NOT NULL,
  `user_message` LONGTEXT NOT NULL,
  `ai_response` LONGTEXT NOT NULL,
  `user_agent` LONGTEXT NULL,
  `page_url` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cid_balance_adjustments` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `delta` INT NOT NULL,
  `balance_after` INT NOT NULL,
  `note` LONGTEXT NULL,
  `adjusted_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cid_balances` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `balance` INT NOT NULL DEFAULT 0,
  `total_added` INT NOT NULL DEFAULT 0,
  `total_used` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cid_generations` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `operator` LONGTEXT NOT NULL,
  `operator_name` LONGTEXT NULL,
  `number` LONGTEXT NULL,
  `result` JSON NULL,
  `status` LONGTEXT NOT NULL,
  `cost` INT NOT NULL DEFAULT 1,
  `provider` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cid_product_credits` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `cid_credits` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `coupons` (
  `id` CHAR(36) NOT NULL,
  `code` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `discount_type` LONGTEXT NOT NULL,
  `discount_value` DECIMAL(20,6) NOT NULL,
  `min_order_amount` DECIMAL(20,6) NULL DEFAULT 0,
  `max_uses` INT NULL,
  `uses_count` INT NULL DEFAULT 0,
  `is_active` TINYINT(1) NULL DEFAULT 1,
  `expires_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `customer_email` LONGTEXT NULL,
  `product_id` CHAR(36) NULL,
  `source` LONGTEXT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `currencies` (
  `id` CHAR(36) NOT NULL,
  `code` LONGTEXT NOT NULL,
  `name` LONGTEXT NOT NULL,
  `symbol` LONGTEXT NOT NULL,
  `rate_from_bdt` DECIMAL(20,6) NOT NULL DEFAULT 1,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `position` INT NOT NULL DEFAULT 0,
  `decimals` SMALLINT NOT NULL DEFAULT 2,
  `symbol_position` LONGTEXT NOT NULL,
  `flag_emoji` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `rate_per_usd` DECIMAL(20,6) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `email_send_log` (
  `id` CHAR(36) NOT NULL,
  `message_id` LONGTEXT NULL,
  `template_name` LONGTEXT NOT NULL,
  `recipient_email` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `error_message` LONGTEXT NULL,
  `metadata` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `email_send_state` (
  `id` INT NOT NULL DEFAULT 1,
  `retry_after_until` DATETIME(3) NULL,
  `batch_size` INT NOT NULL DEFAULT 10,
  `send_delay_ms` INT NOT NULL DEFAULT 200,
  `auth_email_ttl_minutes` INT NOT NULL DEFAULT 15,
  `transactional_email_ttl_minutes` INT NOT NULL DEFAULT 60,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `email_unsubscribe_tokens` (
  `id` CHAR(36) NOT NULL,
  `token` LONGTEXT NOT NULL,
  `email` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `used_at` DATETIME(3) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `global_attribute_values` (
  `id` CHAR(36) NOT NULL,
  `attribute_id` CHAR(36) NOT NULL,
  `value` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `color_code` LONGTEXT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `global_attributes` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `type` LONGTEXT NOT NULL,
  `order_by` LONGTEXT NOT NULL,
  `has_archives` TINYINT(1) NOT NULL DEFAULT 0,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `google_indexing_config` (
  `id` INT NOT NULL DEFAULT 1,
  `service_account_json` LONGTEXT NULL,
  `service_account_email` LONGTEXT NULL,
  `project_id` LONGTEXT NULL,
  `last_tested_at` DATETIME(3) NULL,
  `last_test_ok` TINYINT(1) NULL,
  `last_test_message` LONGTEXT NULL,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `google_indexing_log` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NULL,
  `url` LONGTEXT NOT NULL,
  `notification_type` LONGTEXT NOT NULL,
  `status_code` INT NULL,
  `ok` TINYINT(1) NOT NULL DEFAULT 0,
  `response_body` LONGTEXT NULL,
  `error` LONGTEXT NULL,
  `submitted_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `help_articles` (
  `id` CHAR(36) NOT NULL,
  `title` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `content` LONGTEXT NULL,
  `excerpt` LONGTEXT NULL,
  `category` LONGTEXT NOT NULL,
  `tags` JSON NULL,
  `is_featured` TINYINT(1) NULL DEFAULT 0,
  `helpful_yes` INT NULL DEFAULT 0,
  `helpful_no` INT NULL DEFAULT 0,
  `views` INT NULL DEFAULT 0,
  `status` LONGTEXT NOT NULL,
  `sort_order` INT NULL DEFAULT 0,
  `seo_title` LONGTEXT NULL,
  `seo_description` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `key_check_history` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `key_value` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `error_code` LONGTEXT NULL,
  `product` LONGTEXT NULL,
  `sub_type` LONGTEXT NULL,
  `act_type` LONGTEXT NULL,
  `remaining` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `license_keys` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NULL,
  `order_item_id` CHAR(36) NULL,
  `key_value` LONGTEXT NOT NULL,
  `key_type` LONGTEXT NOT NULL,
  `extra_info` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `assigned_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `delivered_to_phone` LONGTEXT NULL,
  `delivery_batch_id` CHAR(36) NULL,
  `variant` LONGTEXT NULL,
  `key_value_enc` LONGBLOB NULL,
  `extra_info_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletter_subscribers` (
  `id` CHAR(36) NOT NULL,
  `email` LONGTEXT NOT NULL,
  `name` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `source` LONGTEXT NULL,
  `subscribed_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `notices` (
  `id` CHAR(36) NOT NULL,
  `title` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `summary` LONGTEXT NULL,
  `body` LONGTEXT NOT NULL,
  `reference_no` LONGTEXT NULL,
  `audience` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `pinned` TINYINT(1) NOT NULL DEFAULT 0,
  `signed_by` LONGTEXT NULL,
  `signed_role` LONGTEXT NULL,
  `effective_date` DATE NULL,
  `published_at` DATETIME(3) NULL,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `title` LONGTEXT NOT NULL,
  `message` LONGTEXT NOT NULL,
  `type` LONGTEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `link` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offer_blocked_participants` (
  `id` CHAR(36) NOT NULL,
  `offer_id` CHAR(36) NULL,
  `kind` LONGTEXT NOT NULL,
  `identifier` LONGTEXT NOT NULL,
  `reason` LONGTEXT NULL,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offer_facebook_comments` (
  `id` CHAR(36) NOT NULL,
  `offer_id` CHAR(36) NOT NULL,
  `post_url` LONGTEXT NULL,
  `fb_comment_id` LONGTEXT NOT NULL,
  `author_id` LONGTEXT NULL,
  `author_name` LONGTEXT NULL,
  `message` LONGTEXT NULL,
  `like_count` INT NOT NULL DEFAULT 0,
  `fb_created_time` DATETIME(3) NULL,
  `is_winner` TINYINT(1) NOT NULL DEFAULT 0,
  `winner_rank` INT NULL,
  `imported_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offer_fields` (
  `id` CHAR(36) NOT NULL,
  `offer_id` CHAR(36) NOT NULL,
  `field_type` LONGTEXT NOT NULL,
  `label` LONGTEXT NOT NULL,
  `placeholder` LONGTEXT NULL,
  `help_text` LONGTEXT NULL,
  `required` TINYINT(1) NOT NULL DEFAULT 0,
  `options` JSON NULL,
  `validation` JSON NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offer_submissions` (
  `id` CHAR(36) NOT NULL,
  `offer_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NULL,
  `data` JSON NOT NULL,
  `participant_name` LONGTEXT NULL,
  `participant_email` LONGTEXT NULL,
  `participant_phone` LONGTEXT NULL,
  `ip` LONGTEXT NULL,
  `user_agent` LONGTEXT NULL,
  `is_winner` TINYINT(1) NOT NULL DEFAULT 0,
  `winner_rank` INT NULL,
  `prize_won` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `converted_to_customer` TINYINT(1) NOT NULL DEFAULT 0,
  `customer_user_id` CHAR(36) NULL,
  `converted_at` DATETIME(3) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offer_winners` (
  `id` CHAR(36) NOT NULL,
  `offer_id` CHAR(36) NOT NULL,
  `submission_id` CHAR(36) NULL,
  `rank` INT NOT NULL,
  `prize` LONGTEXT NULL,
  `selected_by` LONGTEXT NOT NULL,
  `announced` TINYINT(1) NOT NULL DEFAULT 1,
  `ai_reason` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `participant_name` LONGTEXT NULL,
  `source` LONGTEXT NOT NULL,
  `fb_comment_id` CHAR(36) NULL,
  `participant_contact` LONGTEXT NULL,
  `notes` LONGTEXT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offers` (
  `id` CHAR(36) NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `title` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `banner_url` LONGTEXT NULL,
  `prize_details` LONGTEXT NULL,
  `terms` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `start_at` DATETIME(3) NULL,
  `end_at` DATETIME(3) NULL,
  `max_submissions` INT NULL,
  `require_login` TINYINT(1) NOT NULL DEFAULT 0,
  `success_message` LONGTEXT NULL,
  `google_form_url` LONGTEXT NULL,
  `show_winners` TINYINT(1) NOT NULL DEFAULT 1,
  `submission_count` INT NOT NULL DEFAULT 0,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `notice` LONGTEXT NULL,
  `show_notice` TINYINT(1) NOT NULL DEFAULT 0,
  `auto_publish` TINYINT(1) NOT NULL DEFAULT 0,
  `auto_close` TINYINT(1) NOT NULL DEFAULT 0,
  `max_entries_per_user` INT NOT NULL DEFAULT 1,
  `min_purchase_amount` DECIMAL(20,6) NULL,
  `referral_bonus_entries` INT NOT NULL DEFAULT 0,
  `winner_count` INT NOT NULL DEFAULT 1,
  `winner_selection_mode` LONGTEXT NOT NULL,
  `auto_notify_winners` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `office365_check_history` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `username` LONGTEXT NOT NULL,
  `status_acc` LONGTEXT NOT NULL,
  `checked_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `order_items` (
  `id` CHAR(36) NOT NULL,
  `order_id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NULL,
  `product_name` LONGTEXT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `price` DECIMAL(20,6) NOT NULL,
  `total` DECIMAL(20,6) NOT NULL,
  `license_key` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `custom_field_values` JSON NULL,
  `expires_at` DATETIME(3) NULL,
  `last_reminder_sent_at` DATETIME(3) NULL,
  `license_key_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `order_timeline` (
  `id` CHAR(36) NOT NULL,
  `order_id` CHAR(36) NOT NULL,
  `status` LONGTEXT NOT NULL,
  `note` LONGTEXT NULL,
  `created_by` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `orders` (
  `id` CHAR(36) NOT NULL,
  `order_number` LONGTEXT NOT NULL,
  `customer_name` LONGTEXT NOT NULL,
  `customer_email` LONGTEXT NOT NULL,
  `customer_phone` LONGTEXT NULL,
  `user_id` CHAR(36) NULL,
  `status` VARCHAR(64) NOT NULL,
  `subtotal` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `discount_amount` DECIMAL(20,6) NULL DEFAULT 0,
  `total` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `coupon_id` CHAR(36) NULL,
  `coupon_code` LONGTEXT NULL,
  `payment_method` LONGTEXT NULL,
  `payment_status` LONGTEXT NULL,
  `transaction_id` LONGTEXT NULL,
  `notes` LONGTEXT NULL,
  `admin_notes` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `affiliate_referral_code` LONGTEXT NULL,
  `affiliate_discount_amount` DECIMAL(20,6) NULL DEFAULT 0,
  `deleted_at` DATETIME(3) NULL,
  `deleted_by` CHAR(36) NULL,
  `customer_phone_enc` LONGBLOB NULL,
  `customer_email_enc` LONGBLOB NULL,
  `notes_enc` LONGBLOB NULL,
  `paypal_order_id` LONGTEXT NULL,
  `paypal_capture_id` LONGTEXT NULL,
  `paid_at` DATETIME(3) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `outreach_logs` (
  `id` CHAR(36) NOT NULL,
  `prospect_id` CHAR(36) NOT NULL,
  `event_type` LONGTEXT NOT NULL,
  `channel` LONGTEXT NULL,
  `subject` LONGTEXT NULL,
  `message` LONGTEXT NULL,
  `occurred_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `created_by` CHAR(36) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `outreach_prospects` (
  `id` CHAR(36) NOT NULL,
  `site_name` LONGTEXT NOT NULL,
  `site_url` LONGTEXT NULL,
  `contact_name` LONGTEXT NULL,
  `contact_email` LONGTEXT NULL,
  `contact_channel` LONGTEXT NULL,
  `category` LONGTEXT NULL,
  `domain_authority` INT NULL,
  `status` LONGTEXT NOT NULL,
  `pitch_template` LONGTEXT NULL,
  `notes` LONGTEXT NULL,
  `last_contacted_at` DATETIME(3) NULL,
  `follow_up_at` DATETIME(3) NULL,
  `published_url` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payment_link_submissions` (
  `id` CHAR(36) NOT NULL,
  `payment_link_id` CHAR(36) NULL,
  `link_slug` LONGTEXT NOT NULL,
  `customer_name` LONGTEXT NOT NULL,
  `customer_phone` LONGTEXT NOT NULL,
  `customer_email` LONGTEXT NULL,
  `customer_address` LONGTEXT NULL,
  `product_id` CHAR(36) NULL,
  `product_name` LONGTEXT NOT NULL,
  `product_image` LONGTEXT NULL,
  `amount` DECIMAL(20,6) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `total` DECIMAL(20,6) NOT NULL,
  `payment_method` LONGTEXT NOT NULL,
  `transaction_id` LONGTEXT NOT NULL,
  `sender_number` LONGTEXT NULL,
  `payment_screenshot_url` LONGTEXT NULL,
  `custom_field_values` JSON NOT NULL,
  `customer_note` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `admin_note` LONGTEXT NULL,
  `order_id` CHAR(36) NULL,
  `order_number` LONGTEXT NULL,
  `reviewed_by` CHAR(36) NULL,
  `reviewed_at` DATETIME(3) NULL,
  `ip_address` LONGTEXT NULL,
  `user_agent` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `user_id` CHAR(36) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payment_links` (
  `id` CHAR(36) NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `title` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `product_id` CHAR(36) NULL,
  `product_name` LONGTEXT NULL,
  `product_image` LONGTEXT NULL,
  `amount` DECIMAL(20,6) NULL,
  `original_amount` DECIMAL(20,6) NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `allow_qty_change` TINYINT(1) NOT NULL DEFAULT 0,
  `payment_methods` JSON NOT NULL,
  `required_fields` JSON NOT NULL,
  `custom_fields` JSON NOT NULL,
  `max_uses` INT NULL,
  `current_uses` INT NOT NULL DEFAULT 0,
  `expires_at` DATETIME(3) NULL,
  `status` LONGTEXT NOT NULL,
  `redirect_url` LONGTEXT NULL,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `is_open_form` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payment_proofs` (
  `id` CHAR(36) NOT NULL,
  `order_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NULL,
  `transaction_id` LONGTEXT NOT NULL,
  `screenshot_url` LONGTEXT NULL,
  `payment_method` LONGTEXT NOT NULL,
  `amount` DECIMAL(20,6) NULL,
  `status` LONGTEXT NOT NULL,
  `admin_notes` LONGTEXT NULL,
  `submitted_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `reviewed_at` DATETIME(3) NULL,
  `reviewed_by` CHAR(36) NULL,
  `transaction_id_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `paypal_transactions` (
  `id` CHAR(36) NOT NULL,
  `paypal_order_id` LONGTEXT NULL,
  `paypal_capture_id` LONGTEXT NULL,
  `transaction_id` LONGTEXT NULL,
  `order_id` CHAR(36) NULL,
  `order_number` LONGTEXT NULL,
  `user_id` CHAR(36) NULL,
  `payer_email` LONGTEXT NULL,
  `payer_id` LONGTEXT NULL,
  `payer_name` LONGTEXT NULL,
  `amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `currency` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `mode` LONGTEXT NOT NULL,
  `refunded_amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `raw_create` JSON NULL,
  `raw_capture` JSON NULL,
  `raw_refund` JSON NULL,
  `raw_webhook` JSON NULL,
  `error_message` LONGTEXT NULL,
  `paid_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `personal_licenses` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `category` LONGTEXT NULL,
  `key_value` LONGTEXT NULL,
  `password` LONGTEXT NULL,
  `expires_at` DATETIME(3) NULL,
  `note` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `customer_name` LONGTEXT NULL,
  `customer_phone` LONGTEXT NULL,
  `delivered_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `password_type` LONGTEXT NULL,
  `customer_email` LONGTEXT NULL,
  `last_reminder_sent_at` DATETIME(3) NULL,
  `key_value_enc` LONGBLOB NULL,
  `password_enc` LONGBLOB NULL,
  `note_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `point_transactions` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `type` LONGTEXT NOT NULL,
  `points` INT NOT NULL,
  `balance_after` INT NOT NULL DEFAULT 0,
  `note` LONGTEXT NULL,
  `reference_id` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_attribute_assignments` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `attribute_id` CHAR(36) NULL,
  `custom_name` LONGTEXT NULL,
  `attribute_type` LONGTEXT NOT NULL,
  `selected_values` JSON NOT NULL,
  `is_visible` TINYINT(1) NOT NULL DEFAULT 1,
  `use_in_variation` TINYINT(1) NOT NULL DEFAULT 0,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_categories` (
  `product_id` CHAR(36) NOT NULL,
  `category_id` CHAR(36) NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`product_id`,`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_content_backups` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `description` LONGTEXT NULL,
  `faq` JSON NULL,
  `created_by` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_option_groups` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `display_type` LONGTEXT NOT NULL,
  `is_required` TINYINT(1) NOT NULL DEFAULT 1,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `allow_multiple` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_option_values` (
  `id` CHAR(36) NOT NULL,
  `group_id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NOT NULL,
  `label` LONGTEXT NOT NULL,
  `price_adjustment` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_reviews` (
  `id` CHAR(36) NOT NULL,
  `product_id` CHAR(36) NULL,
  `product_slug` LONGTEXT NOT NULL,
  `user_id` CHAR(36) NULL,
  `author_name` LONGTEXT NOT NULL,
  `author_email` LONGTEXT NULL,
  `rating` INT NOT NULL,
  `title` LONGTEXT NULL,
  `body` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `helpful_count` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `products` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `slug` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `short_description` LONGTEXT NULL,
  `price` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `original_price` DECIMAL(20,6) NULL,
  `discount_percent` INT NULL,
  `sku` LONGTEXT NULL,
  `stock_quantity` INT NULL DEFAULT 0,
  `status` VARCHAR(64) NOT NULL,
  `category_id` CHAR(36) NULL,
  `image_url` LONGTEXT NULL,
  `images` JSON NULL,
  `tags` JSON NULL,
  `is_featured` TINYINT(1) NULL DEFAULT 0,
  `is_digital` TINYINT(1) NULL DEFAULT 1,
  `download_link` LONGTEXT NULL,
  `sort_order` INT NULL DEFAULT 0,
  `total_sales` INT NULL DEFAULT 0,
  `total_views` INT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `delivery_time` LONGTEXT NULL,
  `what_you_get` JSON NULL,
  `faq` JSON NULL,
  `seo_title` LONGTEXT NULL,
  `seo_description` LONGTEXT NULL,
  `variants` JSON NULL,
  `brand` LONGTEXT NULL,
  `cost_price` DECIMAL(20,6) NULL,
  `video_url` LONGTEXT NULL,
  `product_type` LONGTEXT NULL,
  `badge` LONGTEXT NULL,
  `demo_url` LONGTEXT NULL,
  `warranty_note` LONGTEXT NULL,
  `refund_note` LONGTEXT NULL,
  `delivery_type` LONGTEXT NULL,
  `attributes` JSON NULL,
  `subcategory_id` CHAR(36) NULL,
  `custom_fields` JSON NULL,
  `image_alt` LONGTEXT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `profiles` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `display_name` LONGTEXT NULL,
  `email` LONGTEXT NULL,
  `avatar_url` LONGTEXT NULL,
  `phone` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `referral_code` LONGTEXT NULL,
  `referred_by` LONGTEXT NULL,
  `referral_earnings` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `referral_credit` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `referral_discount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `wallet_balance` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `points_balance` INT NOT NULL DEFAULT 0,
  `total_points_earned` INT NOT NULL DEFAULT 0,
  `total_points_redeemed` INT NOT NULL DEFAULT 0,
  `username` LONGTEXT NULL,
  `signup_ip` LONGTEXT NULL,
  `referral_credit_balance` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `is_suspended` TINYINT(1) NOT NULL DEFAULT 0,
  `suspended_at` DATETIME(3) NULL,
  `suspended_reason` LONGTEXT NULL,
  `personal_discount_percent` SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recently_viewed` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `product_id` LONGTEXT NOT NULL,
  `product_name` LONGTEXT NOT NULL,
  `product_price` DECIMAL(20,6) NOT NULL,
  `product_image` LONGTEXT NULL,
  `product_slug` LONGTEXT NULL,
  `viewed_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `referrals` (
  `id` CHAR(36) NOT NULL,
  `referrer_id` CHAR(36) NOT NULL,
  `referred_id` CHAR(36) NULL,
  `referral_code` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `reward_amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `reward_paid` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `signup_attempts` (
  `id` CHAR(36) NOT NULL,
  `ip` LONGTEXT NULL,
  `email` LONGTEXT NULL,
  `user_agent` LONGTEXT NULL,
  `success` TINYINT(1) NOT NULL DEFAULT 0,
  `reason` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `site_settings` (
  `id` CHAR(36) NOT NULL,
  `key` LONGTEXT NOT NULL,
  `value` LONGTEXT NULL,
  `category` LONGTEXT NULL,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `software_downloads` (
  `id` CHAR(36) NOT NULL,
  `name` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `image_url` LONGTEXT NULL,
  `download_url` LONGTEXT NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `support_replies` (
  `id` CHAR(36) NOT NULL,
  `ticket_id` CHAR(36) NOT NULL,
  `author_id` CHAR(36) NULL,
  `author_name` LONGTEXT NOT NULL,
  `is_admin` TINYINT(1) NOT NULL DEFAULT 0,
  `message` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `message_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` CHAR(36) NOT NULL,
  `ticket_number` LONGTEXT NOT NULL,
  `user_id` CHAR(36) NULL,
  `customer_name` LONGTEXT NOT NULL,
  `customer_email` LONGTEXT NOT NULL,
  `customer_phone` LONGTEXT NULL,
  `order_number` LONGTEXT NULL,
  `subject` LONGTEXT NOT NULL,
  `message` LONGTEXT NOT NULL,
  `status` LONGTEXT NOT NULL,
  `priority` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `subject_enc` LONGBLOB NULL,
  `message_enc` LONGBLOB NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `suppressed_emails` (
  `id` CHAR(36) NOT NULL,
  `email` LONGTEXT NOT NULL,
  `reason` LONGTEXT NOT NULL,
  `metadata` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_bot_state` (
  `id` INT NOT NULL,
  `update_offset` BIGINT NOT NULL DEFAULT 0,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_cart` (
  `id` CHAR(36) NOT NULL,
  `chat_id` LONGTEXT NOT NULL,
  `product_id` CHAR(36) NULL,
  `product_name` LONGTEXT NOT NULL,
  `product_slug` LONGTEXT NOT NULL,
  `price` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_checkout_state` (
  `id` CHAR(36) NOT NULL,
  `chat_id` LONGTEXT NOT NULL,
  `step` LONGTEXT NOT NULL,
  `collected_data` JSON NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_checkout_tokens` (
  `id` CHAR(36) NOT NULL,
  `token` LONGTEXT NOT NULL,
  `chat_id` LONGTEXT NOT NULL,
  `cart_data` JSON NOT NULL,
  `is_used` TINYINT(1) NOT NULL DEFAULT 0,
  `expires_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_order_messages` (
  `id` CHAR(36) NOT NULL,
  `telegram_message_id` BIGINT NOT NULL,
  `telegram_chat_id` LONGTEXT NOT NULL,
  `order_id` CHAR(36) NOT NULL,
  `order_number` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telegram_user_prefs` (
  `chat_id` VARCHAR(191) NOT NULL,
  `language` LONGTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `text_overrides` (
  `id` CHAR(36) NOT NULL,
  `key` LONGTEXT NOT NULL,
  `value` LONGTEXT NOT NULL,
  `default_value` LONGTEXT NOT NULL,
  `category` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_cart_items` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `product_id` LONGTEXT NOT NULL,
  `name` LONGTEXT NOT NULL,
  `category` LONGTEXT NULL,
  `image` LONGTEXT NULL,
  `variant` LONGTEXT NOT NULL,
  `price` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `original_price` DECIMAL(20,6) NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_roles` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `role` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wallet_topup_requests` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `amount` DECIMAL(20,6) NOT NULL,
  `payment_method` LONGTEXT NOT NULL,
  `transaction_id` LONGTEXT NOT NULL,
  `screenshot_url` LONGTEXT NULL,
  `status` LONGTEXT NOT NULL,
  `admin_notes` LONGTEXT NULL,
  `reviewed_by` CHAR(36) NULL,
  `reviewed_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wallet_transactions` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `type` LONGTEXT NOT NULL,
  `amount` DECIMAL(20,6) NOT NULL,
  `balance_after` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `note` LONGTEXT NULL,
  `reference_id` LONGTEXT NULL,
  `created_by` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `welcome_coupons` (
  `id` CHAR(36) NOT NULL,
  `code` LONGTEXT NOT NULL,
  `discount_percent` INT NOT NULL,
  `expires_at` DATETIME(3) NOT NULL,
  `is_used` TINYINT(1) NOT NULL DEFAULT 0,
  `visitor_id` LONGTEXT NOT NULL,
  `used_by_order_id` CHAR(36) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `discount_type` LONGTEXT NOT NULL,
  `discount_amount` DECIMAL(20,6) NOT NULL DEFAULT 0,
  `prize_label` LONGTEXT NULL,
  `used_at` DATETIME(3) NULL,
  `ip_hash` LONGTEXT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `whatsapp_bot_config` (
  `id` INT NOT NULL DEFAULT 1,
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `greeting_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `greeting_message` LONGTEXT NOT NULL,
  `away_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `away_message` LONGTEXT NOT NULL,
  `business_hours_start` INT NOT NULL DEFAULT 10,
  `business_hours_end` INT NOT NULL DEFAULT 22,
  `product_reply_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `order_status_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `fallback_message` LONGTEXT NOT NULL,
  `greeting_cooldown_hours` INT NOT NULL DEFAULT 24,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `whatsapp_contacts` (
  `id` CHAR(36) NOT NULL,
  `wa_phone` LONGTEXT NOT NULL,
  `wa_name` LONGTEXT NULL,
  `first_seen_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `last_message_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `last_greeted_at` DATETIME(3) NULL,
  `total_messages` INT NOT NULL DEFAULT 0,
  `is_blocked` TINYINT(1) NOT NULL DEFAULT 0,
  `notes` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `whatsapp_messages` (
  `id` CHAR(36) NOT NULL,
  `wa_phone` LONGTEXT NOT NULL,
  `direction` LONGTEXT NOT NULL,
  `message_type` LONGTEXT NOT NULL,
  `body` LONGTEXT NULL,
  `wa_message_id` LONGTEXT NULL,
  `matched_product_id` CHAR(36) NULL,
  `reply_type` LONGTEXT NULL,
  `raw` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wishlists` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `product_id` LONGTEXT NOT NULL,
  `product_name` LONGTEXT NOT NULL,
  `product_price` DECIMAL(20,6) NOT NULL,
  `product_image` LONGTEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
