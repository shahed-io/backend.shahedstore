import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import nodemailer from 'npm:nodemailer@6.9.13'

export interface SmtpConfig {
  enabled?: boolean
  host?: string
  port?: number
  secure?: boolean
  user?: string
  pass?: string
  from_name?: string
  from_email?: string
}

export interface EmailOptions {
  to: string | string[]
  from?: string
  sender_domain?: string
  subject: string
  html: string
  text?: string
  purpose?: string
  label?: string
  idempotency_key?: string
  unsubscribe_token?: string
  message_id?: string
  run_id?: string
}

// In-memory cache for SMTP config to avoid hitting DB on rapid batch sends
let cachedConfig: SmtpConfig | null = null
let cacheTimestamp = 0
const CACHE_TTL_MS = 30_000 // 30 seconds

/**
 * Fetch SMTP configuration from site_settings table or environment variables.
 */
export async function getSmtpConfig(supabaseClient?: ReturnType<typeof createClient>): Promise<SmtpConfig> {
  const now = Date.now()
  if (cachedConfig && (now - cacheTimestamp < CACHE_TTL_MS)) {
    return cachedConfig
  }

  // 1. Check site_settings table if client provided or create one
  if (!supabaseClient) {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (supabaseUrl && supabaseServiceKey) {
      supabaseClient = createClient(supabaseUrl, supabaseServiceKey)
    }
  }

  let dbConfig: SmtpConfig = {}
  if (supabaseClient) {
    try {
      const { data } = await supabaseClient
        .from('site_settings')
        .select('key, value')
        .in('key', [
          'smtp_config',
          'smtp_host',
          'smtp_port',
          'smtp_user',
          'smtp_pass',
          'smtp_secure',
          'smtp_from_name',
          'smtp_from_email',
          'smtp_enabled',
        ])

      if (data && data.length > 0) {
        const jsonRow = data.find((r: any) => r.key === 'smtp_config')
        if (jsonRow?.value) {
          try {
            dbConfig = JSON.parse(jsonRow.value)
          } catch {
            // Ignore parse error
          }
        }

        // Merge individual keys if present
        data.forEach((r: any) => {
          if (r.key === 'smtp_host' && r.value) dbConfig.host = r.value
          if (r.key === 'smtp_port' && r.value) dbConfig.port = Number(r.value)
          if (r.key === 'smtp_user' && r.value) dbConfig.user = r.value
          if (r.key === 'smtp_pass' && r.value) dbConfig.pass = r.value
          if (r.key === 'smtp_secure' && r.value) dbConfig.secure = r.value === 'true' || r.value === true
          if (r.key === 'smtp_from_name' && r.value) dbConfig.from_name = r.value
          if (r.key === 'smtp_from_email' && r.value) dbConfig.from_email = r.value
          if (r.key === 'smtp_enabled' && r.value) dbConfig.enabled = r.value === 'true' || r.value === true
        })
      }
    } catch (err) {
      console.warn('[email-sender] Failed to read smtp settings from DB:', err)
    }
  }

  // 2. Fall back to environment variables
  const envHost = Deno.env.get('SMTP_HOST')
  const envPort = Deno.env.get('SMTP_PORT')
  const envUser = Deno.env.get('SMTP_USER')
  const envPass = Deno.env.get('SMTP_PASS')
  const envSecure = Deno.env.get('SMTP_SECURE')
  const envFromName = Deno.env.get('SMTP_FROM_NAME')
  const envFromEmail = Deno.env.get('SMTP_FROM_EMAIL') || Deno.env.get('SMTP_FROM')

  const finalConfig: SmtpConfig = {
    enabled: dbConfig.enabled !== false,
    host: dbConfig.host || envHost || 'smtp.hostinger.com',
    port: dbConfig.port || (envPort ? Number(envPort) : 465),
    secure: dbConfig.secure !== undefined ? dbConfig.secure : (envSecure ? envSecure === 'true' : true),
    user: dbConfig.user || envUser || '',
    pass: dbConfig.pass || envPass || '',
    from_name: dbConfig.from_name || envFromName || 'Shahed Store',
    from_email: dbConfig.from_email || envFromEmail || dbConfig.user || envUser || 'noreply@shahedstore.com.bd',
  }

  cachedConfig = finalConfig
  cacheTimestamp = now
  return finalConfig
}

/**
 * Clear the SMTP configuration cache (call after updating settings).
 */
export function invalidateSmtpCache() {
  cachedConfig = null
  cacheTimestamp = 0
}

/**
 * Main unified email sending function.
 * Prioritizes Hostinger SMTP, with optional Lovable email fallback.
 */
export async function sendEmail(
  options: EmailOptions,
  supabaseClient?: ReturnType<typeof createClient>
): Promise<{ success: boolean; messageId?: string; provider: 'smtp' | 'lovable' }> {
  const config = await getSmtpConfig(supabaseClient)

  // ── 1. If Hostinger / custom SMTP is configured, use it ──────────
  if (config.user && config.pass) {
    const isPort465 = config.port === 465
    const isSecure = config.secure !== undefined ? config.secure : isPort465

    const transporter = (nodemailer as any).createTransport({
      host: config.host || 'smtp.hostinger.com',
      port: config.port || 465,
      secure: isSecure, // true for 465, false for 587
      auth: {
        user: config.user,
        pass: config.pass,
      },
      tls: {
        rejectUnauthorized: false, // Prevents certificate chain issues on custom domains
      },
      connectionTimeout: 10_000,
      greetingTimeout: 10_000,
      socketTimeout: 20_000,
    })

    const senderEmail = config.from_email || config.user
    const senderName = config.from_name || 'Shahed Store'
    const fromHeader = `"${senderName}" <${senderEmail}>`

    const toRecipients = Array.isArray(options.to) ? options.to.join(', ') : options.to

    const mailOptions: any = {
      from: fromHeader,
      to: toRecipients,
      subject: options.subject,
      html: options.html,
      text: options.text || options.subject,
    }

    if (options.unsubscribe_token) {
      mailOptions.headers = {
        'List-Unsubscribe': `<https://shahedstore.com.bd/unsubscribe?token=${options.unsubscribe_token}>`,
        'X-Entity-Ref-ID': options.idempotency_key || options.message_id || crypto.randomUUID(),
      }
    }

    const info = await transporter.sendMail(mailOptions)
    console.log(`[email-sender:smtp] Email successfully sent to ${toRecipients} via ${config.host}:${config.port} (Message-ID: ${info.messageId})`)

    return {
      success: true,
      messageId: info.messageId,
      provider: 'smtp',
    }
  }

  // ── 2. Fallback to Lovable Email if API key is present ────────────
  const lovableApiKey = Deno.env.get('LOVABLE_API_KEY')
  if (lovableApiKey) {
    console.log('[email-sender] No SMTP user/pass configured. Falling back to Lovable Email API.')
    const { sendLovableEmail } = await import('npm:@lovable.dev/email-js')

    const recipients = Array.isArray(options.to) ? options.to : [options.to]
    for (const to of recipients) {
      await sendLovableEmail(
        {
          run_id: options.run_id,
          to,
          from: options.from || 'Shahed Store <noreply@shahedstore.com.bd>',
          sender_domain: options.sender_domain || 'shahedstore.com.bd',
          subject: options.subject,
          html: options.html,
          text: options.text || options.subject,
          purpose: (options.purpose as any) || 'transactional',
          label: options.label || 'email',
          idempotency_key: options.idempotency_key || options.message_id || crypto.randomUUID(),
          unsubscribe_token: options.unsubscribe_token,
          message_id: options.message_id || crypto.randomUUID(),
        },
        { apiKey: lovableApiKey }
      )
    }

    return {
      success: true,
      provider: 'lovable',
    }
  }

  // ── 3. Neither configured ─────────────────────────────────────────
  const err = new Error(
    'No email service configured. Please enter your Hostinger Email and Password in the Admin Email Dashboard.'
  )
  console.error('[email-sender:error]', err.message)
  throw err
}
