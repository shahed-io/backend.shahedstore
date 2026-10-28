import { test } from "node:test";
import assert from "node:assert/strict";
import { canRead, canWrite, isSecretSetting } from "../src/access.js";
import { buildWhere } from "../src/filters.js";

const user = { id: "u1", isAdmin: false };

test("visitors can read products but not orders", () => {
  assert.equal(canRead("products", null).ok, true);
  assert.equal(canRead("orders", null).ok, false);
});

test("signed-in users only see their own orders and cannot change them", () => {
  assert.equal(canRead("orders", user).ownerCol, "user_id");
  assert.equal(canWrite("orders", "update", user).ok, false);
});

test("only admins can edit products", () => {
  assert.equal(canWrite("products", "update", user).ok, false);
  assert.equal(canWrite("products", "update", { id: "a", isAdmin: true }).ok, true);
});

test("secret site settings are hidden", () => {
  for (const k of ["bkash_api_key","chatgpt_api","smtp_pass","fb_capi_token","bkash_pgw_config","telegram_chat_id"]) assert.equal(isSecretSetting(k), true, k);
  for (const k of ["hero_slides","announcement_text","site_phone","fb_pixel_id"]) assert.equal(isSecretSetting(k), false, k);
  assert.equal(isSecretSetting("site_name"), false);
});

test("unknown columns are rejected in filters", () => {
  assert.throws(() => buildWhere({ "x;drop": "eq.1" }, { id: {} }));
  assert.deepEqual(buildWhere({ id: "eq.5" }, { id: {} }), { sql: "`id` = ?", params: ["5"] });
});
