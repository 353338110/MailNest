# Security

MailNest is local-first and privacy-focused.

Please report security issues privately instead of opening a public issue.

Rules for contributors:

- Do not store passwords, app passwords, OAuth tokens, or refresh tokens in SQLite.
- Do not log secrets or full email bodies.
- Do not send email content to third-party services by default.
- Keep platform-specific security behavior behind small abstractions.
