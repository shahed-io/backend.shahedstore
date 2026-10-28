// Who may read/write each table. Replaces the old row-level security rules.
// Anything not listed here is ADMIN ONLY.

export const PUBLIC_READ = new Set([
  "products", "categories", "product_categories", "blog_posts", "blog_categories", "blog_tags",
  "blog_post_tags", "help_articles", "software_downloads", "product_reviews", "notices", "currencies",
  "offers", "offer_fields", "global_attributes", "global_attribute_values", "product_option_groups",
  "product_option_values", "product_attribute_assignments", "text_overrides", "site_settings",
]);

// Tables a signed-in user may access, limited to their own rows by this column.
export const OWNER = {
  profiles: { col: "user_id", write: ["update"] },
  addresses: { col: "user_id", write: ["insert", "update", "delete"] },
  user_cart_items: { col: "user_id", write: ["insert", "update", "delete"] },
  wishlists: { col: "user_id", write: ["insert", "delete"] },
  recently_viewed: { col: "user_id", write: ["insert", "update", "delete"] },
  notifications: { col: "user_id", write: ["update"] },
  support_tickets: { col: "user_id", write: ["insert"] },
  orders: { col: "user_id", write: [] },
  wallet_transactions: { col: "user_id", write: [] },
  point_transactions: { col: "user_id", write: [] },
  wallet_topup_requests: { col: "user_id", write: ["insert"] },
  referrals: { col: "referrer_id", write: [] },
};

// Columns a normal user can never change on their own rows.
export const PROTECTED_COLUMNS = new Set([
  "wallet_balance", "points_balance", "total_points_earned", "total_points_redeemed", "referral_credit", "referral_credit_balance", "referral_earnings", "personal_discount_percent", "is_suspended", "user_id", "balance", "role", "is_admin", "status", "total", "amount",
  "payment_status", "is_verified",
]);

// site_settings rows whose key looks secret are never public.
const SECRET_KEY = /(secret|token|password|pass$|api|capi|smtp|telegram|pgw_config|payment_methods_config|getcid|custom_audiences|admin_|notify|private|credential|webhook|config$)/i;
export const isSecretSetting = (key) => SECRET_KEY.test(String(key || ""));

export function canRead(table, user) {
  if (user?.isAdmin) return { ok: true };
  if (PUBLIC_READ.has(table)) return { ok: true };
  if (OWNER[table] && user) return { ok: true, ownerCol: OWNER[table].col };
  return { ok: false };
}

export function canWrite(table, op, user) {
  if (user?.isAdmin) return { ok: true };
  const o = OWNER[table];
  if (o && user && o.write.includes(op)) return { ok: true, ownerCol: o.col };
  return { ok: false };
}
