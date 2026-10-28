import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SITE_URL = 'https://shahedstore.com.bd';
const SITE_NAME = 'Shahed Store';
const SUPABASE_STORAGE_ORIGIN = Deno.env.get('SUPABASE_URL') || 'https://jaqybwsrvknmyyxeqzpm.supabase.co';
const SUPABASE_STORAGE_PUBLIC_PATH = '/storage/v1/object/public/';

const escape = (s: string) =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

const seoAssetUrl = (url?: string | null, fallback = `${SITE_URL}/favicon.png`) => {
  const clean = (url || '').trim();
  if (!clean) return fallback;
  if (clean.startsWith(`${SUPABASE_STORAGE_ORIGIN}${SUPABASE_STORAGE_PUBLIC_PATH}`)) {
    return clean.replace(SUPABASE_STORAGE_ORIGIN, SITE_URL);
  }
  if (clean.startsWith(SUPABASE_STORAGE_PUBLIC_PATH)) return `${SITE_URL}${clean}`;
  if (clean.startsWith('/')) return `${SITE_URL}${clean}`;
  return clean;
};

/** Extract brand from product name */
const extractBrand = (name: string, dbBrand?: string | null): string => {
  if (dbBrand && dbBrand.trim()) return dbBrand.trim();
  const brands = [
    'Microsoft', 'Windows', 'Office', 'Adobe', 'Photoshop', 'Illustrator', 'Premiere',
    'Netflix', 'Spotify', 'YouTube', 'Google', 'Gemini', 'Claude', 'ChatGPT', 'OpenAI',
    'Canva', 'Grammarly', 'NordVPN', 'ExpressVPN', 'Surfshark', 'Kaspersky', 'Norton',
    'Bitdefender', 'ESET', 'Avast', 'McAfee', 'Malwarebytes', 'Trend Micro',
    'Duolingo', 'Coursera', 'Udemy', 'LinkedIn', 'Zoom', 'Slack', 'Dropbox',
    'iCloud', 'Apple', 'Samsung', 'Binance', 'TradingView', 'AutoCAD', 'Autodesk',
    'CorelDRAW', 'Corel', 'WinRAR', 'Discord', 'Steam',
  ];
  const lower = name.toLowerCase();
  for (const brand of brands) {
    if (lower.includes(brand.toLowerCase())) return brand;
  }
  return SITE_NAME;
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const url = new URL(req.url);
    const slug = url.searchParams.get('slug');

    if (!slug) {
      return new Response('Missing slug parameter', { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Fetch product
    const { data: product, error } = await supabase
      .from('products')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'active')
      .single();

    if (error || !product) {
      return new Response('Product not found', { status: 404 });
    }

    // Fetch reviews
    const { data: reviews } = await supabase
      .from('product_reviews_public')
      .select('rating, author_name, body, created_at')
      .eq('product_slug', slug)
      .order('created_at', { ascending: false })
      .limit(10);

    // Fetch category
    let categoryName = '';
    if (product.category_id) {
      const { data: cat } = await supabase
        .from('categories')
        .select('name')
        .eq('id', product.category_id)
        .single();
      if (cat) categoryName = cat.name;
    }

    // Build data
    const brand = extractBrand(product.name, product.brand);
    // Title: "[Product] Price in Bangladesh – ৳{price} | Shahed Store" — matches how BD users search
    const seoTitle = product.seo_title ||
      `${product.name} Price in Bangladesh – ৳${Math.round(product.price).toLocaleString()} | ${SITE_NAME}`;
    const description = product.seo_description || product.short_description ||
      `${product.name} price in Bangladesh ৳${Math.round(product.price).toLocaleString()} BDT. Buy genuine ${categoryName || 'digital'} license from ${SITE_NAME} with instant email delivery. bKash & Nagad accepted. 100% original.`;
    const canonicalUrl = `${SITE_URL}/product/${product.slug}`;
    const mainImageFull = seoAssetUrl(product.image_url);

    // All images
    const allImages: string[] = [];
    if (product.image_url) allImages.push(seoAssetUrl(product.image_url));
    if (Array.isArray(product.images)) {
      for (const img of product.images) {
        const normalized = seoAssetUrl(img, '');
        if (normalized && !allImages.includes(normalized)) allImages.push(normalized);
      }
    }

    // Reviews aggregate
    const reviewCount = reviews?.length || 0;
    const avgRating = reviewCount > 0
      ? (reviews!.reduce((sum, r) => sum + r.rating, 0) / reviewCount).toFixed(1)
      : '4.9';

    // FAQ
    const faqItems = Array.isArray(product.faq) ? product.faq : [];

    const seoImages = allImages.length > 0 ? allImages : [mainImageFull];
    const imageAlt = (product.image_alt || `${product.name} price in Bangladesh ৳${Math.round(product.price).toLocaleString()} - ${SITE_NAME}`).trim();
    const imageObjects = seoImages.map((img, i) => ({
      '@type': 'ImageObject',
      url: img,
      contentUrl: img,
      name: i === 0 ? `${product.name} Price in Bangladesh - Shahed Store` : `${product.name} - Image ${i + 1} | Shahed Store`,
      description: `${product.name} price in Bangladesh ৳${Math.round(product.price).toLocaleString()} - Buy from Shahed Store with instant delivery`,
      caption: `${product.name} price in Bangladesh ৳${Math.round(product.price).toLocaleString()} - ${SITE_NAME}`,
      license: `${SITE_URL}/terms-conditions`,
      acquireLicensePage: canonicalUrl,
      creditText: 'Shahed Store Bangladesh',
      creator: { '@type': 'Organization', name: SITE_NAME, url: SITE_URL },
      representativeOfPage: i === 0,
    }));

    // Schema.org Product — enhanced for Bangladesh Google ranking
    const productSchema: any = {
      '@context': 'https://schema.org',
      '@type': 'Product',
      '@id': `${canonicalUrl}#product`,
      name: product.name,
      alternateName: [
        `${product.name} Bangladesh`,
        `${product.name} বাংলাদেশ`,
        `${product.name} price in bd`,
        `Buy ${product.name} Bangladesh`,
      ],
      description: description,
      image: imageObjects,
      url: canonicalUrl,
      brand: { '@type': 'Brand', name: brand },
      manufacturer: brand !== SITE_NAME ? { '@type': 'Organization', name: brand } : undefined,
      sku: product.sku || product.slug,
      mpn: product.sku || product.slug,
      category: categoryName || 'Digital Software',
      keywords: `${product.name} price in bangladesh, buy ${product.name} bangladesh, ${product.name} bd price, ${product.name} কিনুন, digital software bangladesh, shahed store`,
      offers: {
        '@type': 'Offer',
        url: canonicalUrl,
        priceCurrency: 'BDT',
        price: product.price,
        priceValidUntil: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        availability: 'https://schema.org/InStock',
        itemCondition: 'https://schema.org/NewCondition',
        seller: {
          '@type': 'Organization',
          name: SITE_NAME,
          url: SITE_URL,
          areaServed: { '@type': 'Country', name: 'Bangladesh' },
        },
        shippingDetails: {
          '@type': 'OfferShippingDetails',
          shippingRate: { '@type': 'MonetaryAmount', value: 0, currency: 'BDT' },
          shippingDestination: { '@type': 'DefinedRegion', addressCountry: 'BD' },
          deliveryTime: {
            '@type': 'ShippingDeliveryTime',
            handlingTime: { '@type': 'QuantitativeValue', minValue: 0, maxValue: 1, unitCode: 'HUR' },
            transitTime: { '@type': 'QuantitativeValue', minValue: 0, maxValue: 24, unitCode: 'HUR' },
          },
        },
        ...(product.original_price && product.original_price > product.price ? {
          priceSpecification: {
            '@type': 'UnitPriceSpecification',
            price: product.original_price,
            priceCurrency: 'BDT',
            priceType: 'https://schema.org/ListPrice',
          },
        } : {}),
      },
    };

    if (reviewCount > 0) {
      productSchema.aggregateRating = {
        '@type': 'AggregateRating',
        ratingValue: avgRating,
        reviewCount: reviewCount,
        bestRating: '5',
        worstRating: '1',
      };
      productSchema.review = reviews!.slice(0, 5).map(r => ({
        '@type': 'Review',
        author: { '@type': 'Person', name: r.author_name },
        reviewRating: { '@type': 'Rating', ratingValue: r.rating, bestRating: '5' },
        reviewBody: r.body,
        datePublished: r.created_at?.split('T')[0],
      }));
    }

    // FAQ Schema
    let faqSchema = '';
    if (faqItems.length > 0) {
      const faqJsonLd = {
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        mainEntity: faqItems.map((f: any) => ({
          '@type': 'Question',
          name: f.question || f.q,
          acceptedAnswer: { '@type': 'Answer', text: f.answer || f.a },
        })),
      };
      faqSchema = `<script type="application/ld+json">${JSON.stringify(faqJsonLd)}</script>`;
    }

    // BreadcrumbList Schema
    const breadcrumbSchema = {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: SITE_URL },
        { '@type': 'ListItem', position: 2, name: 'Shop', item: `${SITE_URL}/shop` },
        ...(categoryName ? [{ '@type': 'ListItem', position: 3, name: categoryName, item: `${SITE_URL}/shop?category=${product.category_id}` }] : []),
        { '@type': 'ListItem', position: categoryName ? 4 : 3, name: product.name, item: canonicalUrl },
      ],
    };

    // What you get
    const whatYouGet = Array.isArray(product.what_you_get) ? product.what_you_get : [];

    // Build HTML
    const extraOgImages = allImages
      .filter((img) => img !== mainImageFull)
      .slice(0, 5)
      .map((img) => `  <meta property="og:image" content="${escape(img)}">`)
      .join('\n');

    // SEO keywords for this product
    const seoKeywords = [
      `${product.name} price in bangladesh`,
      `${product.name} bd price`,
      `buy ${product.name} bangladesh`,
      `${product.name} সেরা দাম`,
      `${product.name} কিনুন`,
      categoryName ? `${categoryName} bangladesh` : 'digital software bangladesh',
      'shahed store',
      'shahedstore.com.bd',
    ].filter(Boolean).join(', ');

    const html = `<!DOCTYPE html>
<html lang="bn" dir="ltr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escape(seoTitle)}</title>
  <meta name="description" content="${escape(description.substring(0, 160))}">
  <meta name="keywords" content="${escape(seoKeywords)}">
  <meta name="author" content="${SITE_NAME}">
  <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">
  <meta name="googlebot" content="index, follow, max-snippet:-1, max-image-preview:large">
  <meta name="geo.region" content="BD">
  <meta name="geo.placename" content="Dhaka, Bangladesh">
  <meta name="geo.position" content="23.8103;90.4125">
  <meta name="ICBM" content="23.8103, 90.4125">
  <meta name="language" content="bn">

  <link rel="canonical" href="${canonicalUrl}">
  <link rel="alternate" hreflang="bn-BD" href="${canonicalUrl}">
  <link rel="alternate" hreflang="en" href="${canonicalUrl}">
  <link rel="alternate" hreflang="x-default" href="${canonicalUrl}">

  <meta property="og:title" content="${escape(seoTitle)}">
  <meta property="og:description" content="${escape(description.substring(0, 160))}">
  <meta property="og:type" content="product">
  <meta property="og:url" content="${canonicalUrl}">
  <meta property="og:image" content="${escape(mainImageFull)}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="${escape(imageAlt)}">
${extraOgImages}
  <meta property="og:site_name" content="${SITE_NAME}">
  <meta property="og:locale" content="bn_BD">
  <meta property="og:locale:alternate" content="en_US">
  <meta property="product:price:amount" content="${product.price}">
  <meta property="product:price:currency" content="BDT">

  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escape(seoTitle)}">
  <meta name="twitter:description" content="${escape(description.substring(0, 160))}">
  <meta name="twitter:image" content="${escape(mainImageFull)}">
  <meta name="twitter:image:alt" content="${escape(imageAlt)}">

  <script type="application/ld+json">${JSON.stringify(productSchema)}</script>
  <script type="application/ld+json">${JSON.stringify(breadcrumbSchema)}</script>
  ${faqSchema}
</head>
<body>
  <header>
    <nav aria-label="Breadcrumb">
      <a href="${SITE_URL}">${SITE_NAME}</a> &gt;
      <a href="${SITE_URL}/shop">Shop</a> &gt;
      ${categoryName ? `<a href="${SITE_URL}/shop?category=${escape(product.category_id || '')}">${escape(categoryName)}</a> &gt;` : ''}
      <span aria-current="page">${escape(product.name)}</span>
    </nav>
  </header>

  <main>
    <article itemscope itemtype="https://schema.org/Product">
      <h1 itemprop="name" class="product-title">${escape(product.name)}</h1>
      <p class="lead"><strong>${escape(product.name)}</strong> price in Bangladesh: <span itemprop="price" content="${product.price}"><strong>৳${Math.round(product.price).toLocaleString()}</strong></span> BDT</p>

      ${seoImages.map((img, i) => `<img src="${escape(img)}" alt="${escape(i === 0 ? imageAlt : `${product.name} price in Bangladesh - image ${i + 1} | ${SITE_NAME}`)}" title="${escape(product.name)} - Price in Bangladesh | ${SITE_NAME}" width="800" height="800" loading="${i === 0 ? 'eager' : 'lazy'}" itemprop="image" fetchpriority="${i === 0 ? 'high' : 'auto'}">`).join('\n      ')}

      <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
        <meta itemprop="priceCurrency" content="BDT">
        <p>Price in Bangladesh: <span itemprop="price" content="${product.price}">৳${Math.round(product.price).toLocaleString()}</span> BDT</p>
        ${product.original_price && product.original_price > product.price ? `<p>Original Price: <del>৳${Math.round(product.original_price).toLocaleString()}</del></p>` : ''}
        <link itemprop="availability" href="https://schema.org/InStock">
        <link itemprop="itemCondition" href="https://schema.org/NewCondition">
        <meta itemprop="url" content="${canonicalUrl}">
        <p>Payment: bKash, Nagad, Rocket, Bank Transfer | Delivery: Instant via Email</p>
      </div>

      ${product.short_description ? `<p class="product-description" itemprop="description">${escape(product.short_description)}</p>` : ''}

      ${product.description ? `<section class="product-description"><h2>About ${escape(product.name)}</h2><div>${product.description}</div></section>` : ''}

      ${whatYouGet.length > 0 ? `<section><h2>What You Get</h2><ul>${whatYouGet.map(item => `<li>${escape(String(item))}</li>`).join('')}</ul></section>` : ''}

      ${faqItems.length > 0 ? `<section><h2>Frequently Asked Questions about ${escape(product.name)} in Bangladesh</h2>${faqItems.map((f: any) => `<details><summary>${escape(f.question || f.q || '')}</summary><p>${escape(f.answer || f.a || '')}</p></details>`).join('')}</section>` : ''}

      ${reviewCount > 0 ? `<section><h2>Customer Reviews (${reviewCount})</h2><p>Average Rating: ${avgRating}/5 stars</p>${reviews!.map(r => `<div itemprop="review" itemscope itemtype="https://schema.org/Review"><strong itemprop="author">${escape(r.author_name)}</strong> — ${'&#9733;'.repeat(r.rating)}${'&#9734;'.repeat(5 - r.rating)}<p itemprop="reviewBody">${escape(r.body)}</p></div>`).join('')}</section>` : ''}

      <section>
        <h2>Buy ${escape(product.name)} in Bangladesh</h2>
        <p>Get ${escape(product.name)} at the best price in Bangladesh from Shahed Store. We offer 100% genuine ${escape(categoryName || 'digital')} products with instant delivery via email. Payment accepted: bKash, Nagad, Rocket, and Bank Transfer.</p>
        <ul>
          <li>Price: ৳${Math.round(product.price).toLocaleString()} BDT</li>
          <li>Delivery: Instant via Email</li>
          <li>Payment: bKash, Nagad, Rocket, Bank Transfer</li>
          <li>100% Genuine & Original</li>
          <li>7-day replacement guarantee</li>
        </ul>
        <a href="${canonicalUrl}" title="Buy ${escape(product.name)} Price in Bangladesh">Order Now – ${escape(product.name)}</a>
      </section>
    </article>

    <nav aria-label="Related Links">
      <h2>Explore More</h2>
      <ul>
        <li><a href="${SITE_URL}/shop">All Digital Software Bangladesh</a></li>
        ${categoryName ? `<li><a href="${SITE_URL}/shop?category=${escape(product.category_id || '')}">${escape(categoryName)} Products in Bangladesh</a></li>` : ''}
        <li><a href="${SITE_URL}/faqs">FAQs &amp; Help</a></li>
        <li><a href="${SITE_URL}/contact-us">Contact Shahed Store</a></li>
      </ul>
    </nav>
  </main>

  <footer>
    <p>&copy; ${new Date().getFullYear()} ${SITE_NAME}. All rights reserved.</p>
    <p>Bangladesh's most trusted digital software shop. Buy Windows, Office, Adobe, Netflix, Spotify at best price.</p>
    <nav>
      <a href="${SITE_URL}/about">About Us</a> |
      <a href="${SITE_URL}/contact-us">Contact</a> |
      <a href="${SITE_URL}/privacy-policy">Privacy Policy</a> |
      <a href="${SITE_URL}/refund-policy">Refund Policy</a> |
      <a href="${SITE_URL}/delivery-info">Delivery Info</a>
    </nav>
  </footer>

  <script>
    // Redirect real users to the SPA version
    if (!/bot|crawl|spider|slurp|googlebot|bingbot|yandex|baidu|duckduck|facebookexternalhit|twitterbot|linkedinbot/i.test(navigator.userAgent)) {
      window.location.replace("${canonicalUrl}");
    }
  </script>
</body>
</html>`;

    return new Response(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'public, max-age=1800, s-maxage=86400, stale-while-revalidate=3600',
        'X-Robots-Tag': 'index, follow, max-image-preview:large',
        'Vary': 'User-Agent',
      },
    });
  } catch (error) {
    console.error('Prerender error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
});
