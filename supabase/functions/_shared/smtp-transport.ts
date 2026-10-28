import { EMAIL_FROM_ADDRESS } from './email-identity.ts'
import type { SmtpConfig } from './smtp-config.ts'

export interface EmailOptions {
  to: string | string[]
  // Accepted for existing queue payloads. The server owns the sender identity.
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

type Transport = {
  sendMail: (message: Record<string, unknown>) => Promise<{
    messageId?: string
    accepted?: unknown[]
    rejected?: unknown[]
  }>
  close: () => void
}

export async function sendSmtpEmail(
  options: EmailOptions,
  config: SmtpConfig,
  createTransport: (settings: Record<string, unknown>) => Transport,
): Promise<{ success: true; messageId?: string; provider: 'smtp' }> {
  if (!config.enabled) throw new Error('SMTP email sending is disabled in the Email Dashboard.')
  if (!config.host || !config.user || !config.pass) {
    throw new Error('Hostinger SMTP is not configured. Save the mailbox credentials in the Email Dashboard or server SMTP secrets.')
  }

  const transporter = createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    requireTLS: !config.secure,
    auth: { user: config.user, pass: config.pass },
    tls: { rejectUnauthorized: true, minVersion: 'TLSv1.2' },
    connectionTimeout: 10_000,
    greetingTimeout: 10_000,
    socketTimeout: 20_000,
  })

  try {
    const headers: Record<string, string> = {
      'X-Entity-Ref-ID': options.idempotency_key || options.message_id || crypto.randomUUID(),
    }
    if (options.unsubscribe_token) {
      headers['List-Unsubscribe'] = `<https://shahedstore.com.bd/unsubscribe?token=${encodeURIComponent(options.unsubscribe_token)}>`
    }
    const result = await transporter.sendMail({
      from: { name: config.from_name, address: EMAIL_FROM_ADDRESS },
      to: options.to,
      subject: options.subject,
      html: options.html,
      text: options.text || options.subject,
      headers,
    })
    // SMTP can resolve with rejected recipients. Do not record that as sent.
    if (!result.accepted?.length || result.rejected?.length) {
      throw new Error('Hostinger SMTP did not accept all email recipients.')
    }
    return { success: true, messageId: result.messageId, provider: 'smtp' }
  } finally {
    transporter.close()
  }
}
