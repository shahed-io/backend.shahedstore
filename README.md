# Shahed Store — Backend

এই রিপোজিটরিতে shahedstore.com.bd-এর ব্যাকএন্ড কোড আছে।

## ফোল্ডার
- `express/` — Hostinger-এ চালানোর জন্য Express + MySQL ব্যাকএন্ড (login, data, ছবি)। নির্দেশনা: `express/README.md`।
  - `express/db/schema.sql` — phpMyAdmin দিয়ে MySQL-এ import করুন।
- `supabase/functions/` — বর্তমান চালু ব্যাকএন্ডের সব server function (পেমেন্ট, AI, ইমেইল, Telegram, WhatsApp, SEO ইত্যাদি)। Express-এ এগুলো ধাপে ধাপে নেওয়া বাকি।
- `supabase/migrations/` — বর্তমান ডাটাবেসের পুরো ইতিহাস (টেবিল, নিয়ম, ফাংশন)।

## নিরাপত্তা
এই রিপোজিটরি পাবলিক। এখানে কোনো গ্রাহকের তথ্য, পাসওয়ার্ড, ছবি বা গোপন চাবি রাখা হয়নি এবং রাখবেন না।
গোপন মানগুলো শুধু Hostinger → Environment variables-এ দিন। ডেটা ব্যাকআপ ফাইল সরাসরি সার্ভারে আপলোড করুন।

## Hostinger
Node.js app → এই repo → Root directory `express` → Framework Express → Node 22 → Start `npm start`।
