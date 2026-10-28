import mysql from "mysql2/promise";
import { readFileSync } from "node:fs";

export const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: Number(process.env.DB_POOL) || 8,
  charset: "utf8mb4",
  timezone: "Z",
  dateStrings: false,
});

export const TABLES = JSON.parse(readFileSync(new URL("../db/tables.json", import.meta.url), "utf8"));

/** Convert a JS/CSV value to what MySQL expects for a Postgres column type. */
export function toDb(type, v) {
  if (v === undefined) return undefined;
  if (v === null || v === "") return type === "text" && v === "" ? "" : null;
  switch (type) {
    case "bool":
      return v === true || v === "t" || v === "true" || v === 1 || v === "1" ? 1 : 0;
    case "jsonb":
    case "_text":
      if (typeof v === "string") {
        if (type === "_text" && v.startsWith("{") && !v.startsWith("{\"")) return JSON.stringify(pgArray(v));
        try { JSON.parse(v); return v; } catch { return JSON.stringify(v); }
      }
      return JSON.stringify(v);
    case "timestamptz": {
      const d = new Date(v);
      return isNaN(d) ? null : d.toISOString().replace("T", " ").replace("Z", "");
    }
    case "bytea":
      return typeof v === "string" && v.startsWith("\\x") ? Buffer.from(v.slice(2), "hex") : v;
    default:
      return v;
  }
}

/** Convert a MySQL row back to the JSON shape the website used before. */
export function fromDb(table, row) {
  const cols = TABLES[table]?.columns || {};
  for (const [k, v] of Object.entries(row)) {
    const t = cols[k]?.type;
    if (t === "bool" && v !== null) row[k] = !!v;
    else if ((t === "jsonb" || t === "_text") && typeof v === "string") { try { row[k] = JSON.parse(v); } catch {} }
    else if (t === "numeric" && v !== null) row[k] = Number(v);
    else if (v instanceof Date) row[k] = v.toISOString();
  }
  return row;
}

function pgArray(s) {
  const inner = s.slice(1, -1);
  if (!inner) return [];
  const out = []; let cur = ""; let q = false;
  for (let i = 0; i < inner.length; i++) {
    const c = inner[i];
    if (c === '"' && inner[i - 1] !== "\\") { q = !q; continue; }
    if (c === "," && !q) { out.push(cur); cur = ""; continue; }
    cur += c;
  }
  out.push(cur);
  return out.map((x) => x.replace(/\\"/g, '"'));
}
