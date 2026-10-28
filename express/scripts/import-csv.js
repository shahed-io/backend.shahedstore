// Usage: node scripts/import-csv.js <folder-with-csv-files>
// Imports every <table>.csv from your database backup into MySQL (safe to re-run: existing rows are replaced).
// Optional: put an auth_users.csv (columns: id,email,encrypted_password) in the folder to keep old passwords.
import "dotenv/config";
import { readFileSync, readdirSync, existsSync } from "node:fs";
import path from "node:path";
import { parse } from "csv-parse/sync";
import { pool, TABLES, toDb } from "../src/db.js";

const dir = process.argv[2];
if (!dir || !existsSync(dir)) { console.error("Give the folder that contains the .csv files"); process.exit(1); }

let total = 0;
await pool.query("SET FOREIGN_KEY_CHECKS=0");
for (const file of readdirSync(dir).filter((f) => f.endsWith(".csv")).sort()) {
  const t = path.basename(file, ".csv");
  if (t === "auth_users") continue;
  if (!TABLES[t]) { console.log(`skip ${file} (unknown table)`); continue; }
  const rows = parse(readFileSync(path.join(dir, file)), { columns: true, skip_empty_lines: true, relax_column_count: true });
  const cols = TABLES[t].columns;
  let n = 0;
  for (let i = 0; i < rows.length; i += 200) {
    const batch = rows.slice(i, i + 200);
    const keys = Object.keys(batch[0] || {}).filter((k) => cols[k]);
    if (!keys.length) break;
    const values = batch.map((r) => keys.map((k) => toDb(cols[k].type, r[k])));
    await pool.query(`REPLACE INTO \`${t}\` (${keys.map((k) => `\`${k}\``).join(",")}) VALUES ?`, [values]);
    n += batch.length;
  }
  total += n;
  console.log(`${t}: ${n} rows`);
}

// Accounts: every profile becomes a login account. Without old password hashes, users use "Forgot password".
const authFile = path.join(dir, "auth_users.csv");
const hashes = existsSync(authFile) ? parse(readFileSync(authFile), { columns: true }) : [];
const [profiles] = await pool.query("SELECT user_id AS id, email FROM profiles WHERE email IS NOT NULL AND email <> ''");
const byId = new Map(hashes.map((h) => [h.id, h.encrypted_password || null]));
for (const p of profiles) {
  await pool.query("INSERT INTO app_users (id,email,password_hash) VALUES (?,?,?) ON DUPLICATE KEY UPDATE password_hash=COALESCE(password_hash, VALUES(password_hash))",
    [p.id, String(p.email).toLowerCase(), byId.get(p.id) || null]).catch((e) => console.log(`account skip ${p.email}: ${e.code}`));
}
await pool.query("SET FOREIGN_KEY_CHECKS=1");
console.log(`Done. ${total} rows imported, ${profiles.length} accounts, ${hashes.length} with old passwords.`);
await pool.end();
