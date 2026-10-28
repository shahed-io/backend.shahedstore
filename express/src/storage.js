import { Router, static as serveStatic } from "express";
import multer from "multer";
import { mkdirSync } from "node:fs";
import path from "node:path";
import { randomUUID } from "node:crypto";
import { httpError } from "./filters.js";

// Files live in ./uploads/<bucket>/<path>. Copy your downloaded storage files there.
const ROOT = path.resolve(process.env.UPLOAD_DIR || "uploads");
const PUBLIC_BUCKETS = new Set((process.env.PUBLIC_BUCKETS || "product-images,software-images,category-images,email-assets").split(","));
const USER_BUCKETS = new Set(["payment-proofs", "refund-screenshots"]);
const ALLOWED = /\.(png|jpe?g|webp|gif|svg|avif|pdf|ico)$/i;
const safe = (s) => /^[a-z0-9._-]+$/i.test(s);

export const storageRouter = Router();

storageRouter.get("/:bucket/*", (req, res, next) => {
  if (!safe(req.params.bucket)) return next(httpError(400, "Bad bucket"));
  if (!PUBLIC_BUCKETS.has(req.params.bucket) && !req.user?.isAdmin) return next(httpError(403, "Not allowed"));
  serveStatic(path.join(ROOT, req.params.bucket), { maxAge: "30d", fallthrough: false })(
    Object.assign(req, { url: "/" + req.params[0] }), res, next,
  );
});

const upload = multer({
  limits: { fileSize: 10 * 1024 * 1024 },
  storage: multer.diskStorage({
    destination: (req, _f, cb) => { const d = path.join(ROOT, req.params.bucket); mkdirSync(d, { recursive: true }); cb(null, d); },
    filename: (_req, f, cb) => cb(null, `${Date.now()}-${randomUUID().slice(0, 8)}${path.extname(f.originalname).toLowerCase()}`),
  }),
  fileFilter: (_req, f, cb) => cb(ALLOWED.test(f.originalname) ? null : httpError(400, "File type not allowed"), true),
});

storageRouter.post("/:bucket", (req, _res, next) => {
  const b = req.params.bucket;
  if (!safe(b)) return next(httpError(400, "Bad bucket"));
  if (!req.user) return next(httpError(401, "Sign in first"));
  if (!req.user.isAdmin && !USER_BUCKETS.has(b)) return next(httpError(403, "Not allowed"));
  next();
}, upload.single("file"), (req, res) => {
  const base = process.env.PUBLIC_URL || "";
  res.status(201).json({ path: req.file.filename, url: `${base}/storage/${req.params.bucket}/${req.file.filename}` });
});
