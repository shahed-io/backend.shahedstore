# Shahed Store Backend (Express + MySQL) — Hostinger

Your own backend: all 94 tables, accounts/login, file storage, and a safe data API.
It runs on Hostinger Node.js hosting and deploys from GitHub.

## 1. Put it on GitHub
1. github.com → **New repository** → name `shahedstore-backend` → **Private** → Create.
2. Click **uploading an existing file**, drag in everything from this ZIP (not `node_modules`), **Commit**.

## 2. Create the MySQL database (Hostinger hPanel)
1. **Databases → MySQL Databases** → create database + user, write down the names and password.
2. Open **phpMyAdmin** → select the database → **Import** → choose `db/schema.sql` → Go.

## 3. Create the Node.js app from GitHub
1. hPanel → **Websites → Add website → Node.js app → Import Git repository** → pick `shahedstore-backend`.
2. Framework: **Express**. Node version: **20** or newer. Entry file: `server.js`. Start command: `npm start`.
3. Domain: use a subdomain such as `api.shahedstore.com.bd`.
4. **Environment variables**: copy the names from `.env.example` and fill in your real values
   (database name/user/password, a long random `JWT_SECRET`, SMTP email details).
5. Deploy. Open `https://api.shahedstore.com.bd/health` → should show `{"ok":true,"database":"connected"}`.

## 4. Load your backup data
On your computer (Node 20 installed), unzip the database backup into a folder, then:
```
npm install
# create a .env file with the same values as step 3 (DB_HOST = the remote MySQL host from hPanel)
npm run import -- ./backup-folder
```
Enable **Remote MySQL** in hPanel for your computer's IP first. Safe to run again.
Passwords: users without an old password hash use **Forgot password** once.
If your official export contains the users table, save it as `auth_users.csv` (id,email,encrypted_password) in the folder — old passwords then keep working.

## 5. Files (images)
Download your storage files (Lovable → More → Storage) and upload them with hPanel **File Manager** into
`uploads/<bucket-name>/` inside the app folder, e.g. `uploads/product-images/...`.
They are served at `https://api.shahedstore.com.bd/storage/product-images/<file>`.

## API
- `POST /auth/signup`, `POST /auth/login`, `GET /auth/me`, `POST /auth/forgot`, `POST /auth/reset`
- `GET /rest/<table>?select=a,b&col=eq.value&order=created_at.desc&limit=20`
  filters: eq, neq, gt, gte, lt, lte, like, ilike, in.(a,b), is.null
- `POST /rest/<table>` (insert), `PATCH /rest/<table>?id=eq.X` (update), `DELETE /rest/<table>?id=eq.X`
- `POST /storage/<bucket>` (form field `file`), `GET /storage/<bucket>/<path>`
- Send `Authorization: Bearer <access_token>` after login.

Access rules are in `src/access.js` (public read / own rows only / admin only). Run `npm test` after changing them.

## Not included yet (phase 2)
Payment gateways (bKash, Binance, SSLCommerz), AI tools, Telegram/WhatsApp bots, order emails,
scheduled jobs, and switching the website itself to this API. Until then the live website keeps using the current backend.
