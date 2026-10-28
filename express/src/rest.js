import { Router } from "express";
import { randomUUID } from "node:crypto";
import { pool, TABLES, toDb, fromDb } from "./db.js";
import { canRead, canWrite, isSecretSetting, PROTECTED_COLUMNS } from "./access.js";
import { buildWhere, buildSelect, buildOrder, httpError } from "./filters.js";

export const restRouter = Router();

function table(req) {
  const t = req.params.table;
  if (!TABLES[t]) throw httpError(404, "Unknown table");
  return t;
}

function withOwner(where, ownerCol, user) {
  if (!ownerCol) return where;
  return { sql: `(${where.sql}) AND \`${ownerCol}\` = ?`, params: [...where.params, user.id] };
}

function cleanRow(t, body, user, isInsert) {
  const cols = TABLES[t].columns;
  const row = {};
  for (const [k, v] of Object.entries(body || {})) {
    if (!cols[k]) throw httpError(400, `Unknown column: ${k}`);
    if (!user?.isAdmin && PROTECTED_COLUMNS.has(k)) continue;
    row[k] = toDb(cols[k].type, v);
  }
  if (isInsert) {
    for (const [k, c] of Object.entries(cols)) {
      if (row[k] !== undefined) continue;
      if (c.default === "__uuid") row[k] = randomUUID();
      else if (c.default === "__now") row[k] = toDb("timestamptz", new Date());
      else if (c.default !== null && c.default !== undefined) row[k] = toDb(c.type, c.default);
    }
  }
  return row;
}

restRouter.get("/:table", async (req, res, next) => {
  try {
    const t = table(req);
    const perm = canRead(t, req.user);
    if (!perm.ok) throw httpError(req.user ? 403 : 401, "Not allowed");
    const cols = TABLES[t].columns;
    let where = withOwner(buildWhere(req.query, cols), perm.ownerCol, req.user);
    const limit = Math.min(Number(req.query.limit) || 1000, 5000);
    const offset = Math.max(Number(req.query.offset) || 0, 0);
    const sql = `SELECT ${buildSelect(req.query.select, cols)} FROM \`${t}\` WHERE ${where.sql}${buildOrder(req.query.order, cols)} LIMIT ${limit} OFFSET ${offset}`;
    const [rows] = await pool.query(sql, where.params);
    let out = rows.map((r) => fromDb(t, r));
    if (t === "site_settings" && !req.user?.isAdmin) out = out.filter((r) => !isSecretSetting(r.key));
    res.json(out);
  } catch (e) { next(e); }
});

restRouter.post("/:table", async (req, res, next) => {
  try {
    const t = table(req);
    const perm = canWrite(t, "insert", req.user);
    if (!perm.ok) throw httpError(req.user ? 403 : 401, "Not allowed");
    const items = Array.isArray(req.body) ? req.body : [req.body];
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
      const inserted = [];
      for (const item of items) {
        const row = cleanRow(t, item, req.user, true);
        if (perm.ownerCol) row[perm.ownerCol] = req.user.id;
        const keys = Object.keys(row);
        await conn.query(`INSERT INTO \`${t}\` (${keys.map((k) => `\`${k}\``).join(",")}) VALUES (${keys.map(() => "?").join(",")})`, keys.map((k) => row[k]));
        inserted.push(row);
      }
      await conn.commit();
      res.status(201).json(inserted.map((r) => fromDb(t, { ...r })));
    } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
  } catch (e) { next(e); }
});

restRouter.patch("/:table", async (req, res, next) => {
  try {
    const t = table(req);
    const perm = canWrite(t, "update", req.user);
    if (!perm.ok) throw httpError(req.user ? 403 : 401, "Not allowed");
    const cols = TABLES[t].columns;
    const where = withOwner(buildWhere(req.query, cols), perm.ownerCol, req.user);
    if (where.sql.startsWith("(1=1)") || where.sql === "1=1") if (!req.user?.isAdmin || !req.query.confirm_all) throw httpError(400, "A filter is required");
    const row = cleanRow(t, req.body, req.user, false);
    if (perm.ownerCol) delete row[perm.ownerCol];
    const keys = Object.keys(row);
    if (!keys.length) throw httpError(400, "Nothing to update");
    const [r] = await pool.query(`UPDATE \`${t}\` SET ${keys.map((k) => `\`${k}\`=?`).join(",")} WHERE ${where.sql}`, [...keys.map((k) => row[k]), ...where.params]);
    res.json({ updated: r.affectedRows });
  } catch (e) { next(e); }
});

restRouter.delete("/:table", async (req, res, next) => {
  try {
    const t = table(req);
    const perm = canWrite(t, "delete", req.user);
    if (!perm.ok) throw httpError(req.user ? 403 : 401, "Not allowed");
    const where = withOwner(buildWhere(req.query, TABLES[t].columns), perm.ownerCol, req.user);
    if (where.sql === "1=1" || where.sql.startsWith("(1=1)")) throw httpError(400, "A filter is required");
    const [r] = await pool.query(`DELETE FROM \`${t}\` WHERE ${where.sql}`, where.params);
    res.json({ deleted: r.affectedRows });
  } catch (e) { next(e); }
});
