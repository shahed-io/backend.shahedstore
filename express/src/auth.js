import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import rateLimit from "express-rate-limit";
import nodemailer from "nodemailer";
import { randomUUID, randomBytes, createHash } from "node:crypto";
import { pool } from "./db.js";
import { httpError } from "./filters.js";

export const authRouter = Router();
const limiter = rateLimit({ windowMs: 15 * 60_000, limit: 20 });
const sha = (s) => createHash("sha256").update(s).digest("hex");
const emailOk = (e) => typeof e === "string" && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e) && e.length < 190;

async function isAdmin(userId) {
  const [r] = await pool.query("SELECT 1 FROM user_roles WHERE user_id=? AND role IN ('admin','manager') LIMIT 1", [userId]);
  return r.length > 0;
}

async function issue(user) {
  const admin = await isAdmin(user.id);
  const token = jwt.sign({ sub: user.id, email: user.email, admin }, process.env.JWT_SECRET, { expiresIn: "7d" });
  return { access_token: token, user: { id: user.id, email: user.email, is_admin: admin } };
}

/** Reads the Bearer token if present. Admin status is re-checked from the database. */
export async function authOptional(req, _res, next) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) return next();
  try {
    const p = jwt.verify(h.slice(7), process.env.JWT_SECRET);
    req.user = { id: p.sub, email: p.email, isAdmin: await isAdmin(p.sub) };
  } catch { /* invalid token = signed out */ }
  next();
}

authRouter.post("/signup", limiter, async (req, res, next) => {
  try {
    const { email, password, full_name } = req.body || {};
    if (!emailOk(email)) throw httpError(400, "Invalid email");
    if (typeof password !== "string" || password.length < 8) throw httpError(400, "Password must be at least 8 characters");
    const id = randomUUID();
    const e = email.toLowerCase().trim();
    try {
      await pool.query("INSERT INTO app_users (id,email,password_hash) VALUES (?,?,?)", [id, e, await bcrypt.hash(password, 10)]);
    } catch (err) {
      if (err.code === "ER_DUP_ENTRY") throw httpError(409, "Email already registered");
      throw err;
    }
    await pool.query("INSERT IGNORE INTO profiles (id,user_id,email,display_name,created_at,updated_at) VALUES (?,?,?,?,NOW(3),NOW(3))", [randomUUID(), id, e, full_name || null]).catch(() => {});
    await pool.query("INSERT IGNORE INTO user_roles (id,user_id,role) VALUES (?,?, 'user')", [randomUUID(), id]).catch(() => {});
    res.status(201).json(await issue({ id, email: e }));
  } catch (e) { next(e); }
});

authRouter.post("/login", limiter, async (req, res, next) => {
  try {
    const { email, password } = req.body || {};
    if (!emailOk(email) || typeof password !== "string") throw httpError(400, "Invalid login");
    const [rows] = await pool.query("SELECT * FROM app_users WHERE email=?", [email.toLowerCase().trim()]);
    const u = rows[0];
    if (!u?.password_hash) throw httpError(401, u ? "Please reset your password first" : "Wrong email or password");
    // Old accounts use bcrypt ($2a$) hashes too, so imported passwords keep working.
    if (!(await bcrypt.compare(password, u.password_hash))) throw httpError(401, "Wrong email or password");
    res.json(await issue(u));
  } catch (e) { next(e); }
});

authRouter.get("/me", (req, res) => {
  if (!req.user) return res.status(401).json({ error: "Not signed in" });
  res.json({ id: req.user.id, email: req.user.email, is_admin: req.user.isAdmin });
});

authRouter.post("/forgot", limiter, async (req, res, next) => {
  try {
    const email = String(req.body?.email || "").toLowerCase().trim();
    const [rows] = await pool.query("SELECT id FROM app_users WHERE email=?", [email]);
    if (rows[0] && process.env.SMTP_HOST) {
      const token = randomBytes(32).toString("hex");
      await pool.query("UPDATE app_users SET reset_token_hash=?, reset_expires=DATE_ADD(NOW(3), INTERVAL 1 HOUR) WHERE id=?", [sha(token), rows[0].id]);
      const link = `${process.env.SITE_URL || "https://shahedstore.com.bd"}/reset-password?token=${token}`;
      const t = nodemailer.createTransport({ host: process.env.SMTP_HOST, port: Number(process.env.SMTP_PORT) || 465, secure: true, auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS } });
      await t.sendMail({ from: process.env.SMTP_FROM || process.env.SMTP_USER, to: email, subject: "Reset your Shahed Store password", text: `Open this link to set a new password (valid 1 hour):\n${link}` });
    }
    res.json({ ok: true }); // same answer whether or not the email exists
  } catch (e) { next(e); }
});

authRouter.post("/reset", limiter, async (req, res, next) => {
  try {
    const { token, password } = req.body || {};
    if (typeof password !== "string" || password.length < 8) throw httpError(400, "Password must be at least 8 characters");
    const [rows] = await pool.query("SELECT * FROM app_users WHERE reset_token_hash=? AND reset_expires > NOW(3)", [sha(String(token || ""))]);
    if (!rows[0]) throw httpError(400, "Link expired or invalid");
    await pool.query("UPDATE app_users SET password_hash=?, reset_token_hash=NULL, reset_expires=NULL WHERE id=?", [await bcrypt.hash(password, 10), rows[0].id]);
    res.json(await issue(rows[0]));
  } catch (e) { next(e); }
});
