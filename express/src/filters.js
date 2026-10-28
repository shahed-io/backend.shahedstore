// Small, safe subset of the old query style: ?col=eq.value&order=col.desc&limit=10
const OPS = { eq: "=", neq: "<>", gt: ">", gte: ">=", lt: "<", lte: "<=", like: "LIKE", ilike: "LIKE" };
const RESERVED = new Set(["select", "order", "limit", "offset"]);

export function buildWhere(query, columns) {
  const parts = [];
  const params = [];
  for (const [col, raw] of Object.entries(query)) {
    if (RESERVED.has(col)) continue;
    if (!columns[col]) throw httpError(400, `Unknown column: ${col}`);
    const values = Array.isArray(raw) ? raw : [raw];
    for (const val of values) {
      const s = String(val);
      const dot = s.indexOf(".");
      const op = s.slice(0, dot);
      const arg = s.slice(dot + 1);
      if (op === "in") {
        const list = arg.replace(/^\(|\)$/g, "").split(",").filter(Boolean);
        if (!list.length) { parts.push("1=0"); continue; }
        parts.push(`\`${col}\` IN (${list.map(() => "?").join(",")})`);
        params.push(...list);
      } else if (op === "is") {
        if (arg === "null") parts.push(`\`${col}\` IS NULL`);
        else if (arg === "true" || arg === "false") { parts.push(`\`${col}\` = ?`); params.push(arg === "true" ? 1 : 0); }
        else throw httpError(400, "Bad is. filter");
      } else if (OPS[op]) {
        parts.push(`\`${col}\` ${OPS[op]} ?`);
        params.push(op.endsWith("like") ? arg.replace(/\*/g, "%") : arg === "true" ? 1 : arg === "false" ? 0 : arg);
      } else throw httpError(400, `Bad filter on ${col}`);
    }
  }
  return { sql: parts.length ? parts.join(" AND ") : "1=1", params };
}

export function buildSelect(select, columns) {
  if (!select || select === "*") return "*";
  const cols = String(select).split(",").map((c) => c.trim()).filter(Boolean);
  for (const c of cols) if (!columns[c]) throw httpError(400, `Unknown column: ${c}`);
  return cols.map((c) => `\`${c}\``).join(",");
}

export function buildOrder(order, columns) {
  if (!order) return "";
  const items = String(order).split(",").map((o) => {
    const [c, dir] = o.split(".");
    if (!columns[c]) throw httpError(400, `Unknown column: ${c}`);
    return `\`${c}\` ${dir === "desc" ? "DESC" : "ASC"}`;
  });
  return ` ORDER BY ${items.join(",")}`;
}

export function httpError(status, message) {
  const e = new Error(message);
  e.status = status;
  e.expose = true;
  return e;
}
