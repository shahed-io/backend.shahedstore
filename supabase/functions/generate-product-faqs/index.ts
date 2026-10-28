import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { callAIWithFallback } from "../_shared/ai-fallback.ts";
import { normalizeBrandNameText } from "../_shared/brand-name.ts";
import { requireAdmin } from "../_shared/admin-auth.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  const authFail = await requireAdmin(req);
  if (authFail) return authFail;

  try {
    const { product, count = 5, language = "bn" } = await req.json();
    if (!product?.name) throw new Error("product.name required");

    // Enforce correct store name based on language — always use English "Shahed Store"
    const storeName = "Shahed Store";
    const nameRule = `STORE NAME RULE: Always use the English spelling "Shahed Store" for our brand name in all sentences. Do NOT use the Bengali spelling "শাহেদ স্টোর" under any circumstances.`;
    const prompt = `You are a Senior SEO Copywriter and Content Expert for "${storeName}", a premium digital software store in Bangladesh.

${nameRule}

Generate exactly 3 to 5 high-quality, Google-ranking-friendly FAQs for the product below. Mix product-specific questions (features, activation, delivery, warranty) and store-trust questions (about ${storeName}, payment safety, support).

Write the questions and answers using a highly professional and elegant combination of Bengali and English (mixing English tech terms naturally into Bengali sentences, such as "Premium access", "Secure payment", "After-sales support"). The tone must be authoritative, assuring, and beautiful — exactly how a senior writer would craft premium copy. Answers must be 2-4 sentences, specific, helpful, and include relevant keywords. Avoid generic filler. Do NOT use markdown.

Product:
- Name: ${product.name}
- Category: ${product.category || "Digital Product"}
- Price: ৳${product.price || "N/A"}
- Description: ${(product.description || product.short_description || "").slice(0, 800)}
- Delivery time: ${product.delivery_time || "1-24 hours"}

Return ONLY a valid JSON array, no prose, no code fences. Schema:
[{"q":"question text","a":"answer text"}, ...]`;

    const { text } = await callAIWithFallback({
      model: "google/gemini-2.5-flash",
      messages: [
        { role: "system", content: "You output ONLY valid JSON arrays. No markdown, no prose." },
        { role: "user", content: prompt },
      ],
    });

    // Extract JSON
    let jsonStr = text.trim();
    const fenced = jsonStr.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (fenced) jsonStr = fenced[1].trim();
    const start = jsonStr.indexOf("[");
    const end = jsonStr.lastIndexOf("]");
    if (start >= 0 && end > start) jsonStr = jsonStr.slice(start, end + 1);

    let faqs: { q: string; a: string }[] = [];
    try {
      faqs = JSON.parse(jsonStr);
    } catch {
      throw new Error("AI did not return valid JSON");
    }
    faqs = (faqs || [])
      .filter((f) => f && typeof f.q === "string" && typeof f.a === "string" && f.q.trim() && f.a.trim())
      .map((f) => ({ q: normalizeBrandNameText(f.q.trim()), a: normalizeBrandNameText(f.a.trim()) }));

    if (!faqs.length) throw new Error("No FAQs generated");

    return new Response(JSON.stringify({ faqs }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("generate-product-faqs error:", e);
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
