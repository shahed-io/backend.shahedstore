import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { pool } from "./src/db.js";
import { authRouter, authOptional } from "./src/auth.js";
import { restRouter } from "./src/rest.js";
import { storageRouter } from "./src/storage.js";

for (const k of ["DB_HOST", "DB_USER", "DB_NAME", "JWT_SECRET"]) {
  if (!process.env[k]) console.error(`Missing environment variable: ${k}`);
}

const app = express();
app.set("trust proxy", 1);
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
const origins = (process.env.CORS_ORIGINS || "https://shahedstore.com.bd").split(",").map((s) => s.trim());
app.use(cors({ origin: origins, credentials: true }));
app.use(express.json({ limit: "2mb" }));
app.use(rateLimit({ windowMs: 60_000, limit: 300, standardHeaders: true, legacyHeaders: false }));
app.use(authOptional);

app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ ok: true, database: "connected" });
  } catch {
    res.status(503).json({ ok: false, database: "unreachable" });
  }
});

app.use("/auth", authRouter);
app.use("/rest", restRouter);
app.use("/storage", storageRouter);

app.use((_req, res) => res.status(404).json({ error: "Not found" }));
app.use((err, _req, res, _next) => {
  console.error(err?.message || err);
  res.status(err.status || 500).json({ error: err.expose ? err.message : "Server error" });
});

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => console.log(`Shahed Store backend running on port ${port}`));
