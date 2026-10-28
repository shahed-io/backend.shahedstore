import { EMAIL_FROM_ADDRESS, EMAIL_FROM_NAME } from './email-identity.ts'

export interface SmtpConfig {
  enabled: boolean
  host: string
  port: number
  secure: boolean
  user: string
  pass: string
  from_name: string
  from_email: string
}

type SettingRow = { key: string; value: unknown }
type Environment = Record<string, string | undefined>

function nonEmptyString(value: unknown): string | undefined {
  return typeof value === 'string' && value.trim() ? value : undefined
}

function booleanValue(value: unknown): boolean | undefined {
  if (value === true || value === 'true') return true
  if (value === false || value === 'false') return false
  return undefined
}

// Legacy JSON and individual settings remain supported. Individual keys win,
// followed by the JSON record, then server-side environment variables.
export function resolveSmtpConfig(rows: SettingRow[], env: Environment): SmtpConfig {
  let stored: Record<string, unknown> = {}
  const json = rows.find(row => row.key === 'smtp_config')?.value
  if (typeof json === 'string') {
    try {
      const parsed = JSON.parse(json)
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) stored = parsed
    } catch { /* Older installs may only have individual settings. */ }
  }

  for (const row of rows) {
    if (row.key.startsWith('smtp_') && row.key !== 'smtp_config' && row.value !== '' && row.value != null) {
      stored[row.key.slice(5)] = row.value
    }
  }

  const port = Number(stored.port ?? env.SMTP_PORT ?? 465)
  if (port !== 465 && port !== 587) {
    throw new Error('Hostinger SMTP port must be 465 (SSL) or 587 (STARTTLS).')
  }

  return {
    enabled: booleanValue(stored.enabled) ?? booleanValue(env.SMTP_ENABLED) ?? true,
    host: (nonEmptyString(stored.host) ?? env.SMTP_HOST ?? 'smtp.hostinger.com').trim(),
    port,
    // Derive encryption from the port even if an old setting is inconsistent.
    secure: port === 465,
    user: (nonEmptyString(stored.user) ?? env.SMTP_USER ?? EMAIL_FROM_ADDRESS).trim(),
    pass: nonEmptyString(stored.pass) ?? env.SMTP_PASS ?? '',
    from_name: nonEmptyString(stored.from_name) ?? env.SMTP_FROM_NAME ?? EMAIL_FROM_NAME,
    // Old settings, environment variables and queued payloads cannot change From.
    from_email: EMAIL_FROM_ADDRESS,
  }
}
