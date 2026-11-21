# Security setup

**Last updated:** 2026-11-20

This page separates what is in place today from what the project plan commits to building later. Nothing under "Planned" exists yet.

## In place

### Identity and access

- **Separate personal tenant.** ClaimPilot runs in its own Microsoft Entra directory and Azure subscription, created from a personal Microsoft account. No employer account, tenant or equipment is involved.
- **Multi-factor authentication.** Two-step verification is turned on for the personal admin account, and its recovery code is stored offline.
- **Security defaults.** Enabled in Entra ID. Every user in the directory must register an authenticator, admins are prompted for MFA, and legacy sign-in methods are blocked.
- **Emergency admin.** A second Global Administrator account lives inside the directory, so losing access to the personal account does not lock the tenant. It has an authenticator registered and its credentials are stored offline.

### Cost and region

- **Budget alert.** A monthly budget of $50 is set on the subscription, with alert thresholds and an email recipient configured. A budget only sends alerts; it does not stop resources running.
- **Resource group.** `rg-claimpilot-dev` in East US, tagged with `project` and `env`. All project resources go in this one group, and the US region keeps data in the US as the privacy controls require.

### Repository

- **Ignore rules.** `.gitignore` excludes environment files, key files and local settings.
- **Session logs stay local.** `docs/session-logs/` is ignored and never pushed.
- **GitHub scanning.** The repository is public, with secret scanning, push protection and Dependabot alerts turned on. Code scanning is left off until there is Python and C# code to analyse.

## Planned

From the project plan. Each item moves to "In place" when it is built.

| Area | Control | When |
| --- | --- | --- |
| Identity | The agent runs under its own managed identity with read-only access | Week 3 |
| Identity | Adjusters sign in with Entra ID | Week 5 |
| Secrets | Held in Key Vault; none in code, prompts or logs | From the first secret |
| Prompt injection | Loss descriptions and police reports are treated as data, never as instructions | Week 3 |
| Limits on the agent | Read-only tools; only the claims API records a routing, after approval | Week 3 |
| Output checks | Schema validation, forced injury queue, confidence floor of 0.7, Azure Content Safety | Week 5 |
| Privacy | Personal data redacted before logs, traces and evaluation sets; traces kept 30 days | Week 5 |
| Audit | Every recommendation, approval, edit and rejection is recorded | Week 5 |
| Supply chain | Dependency and secret scanning in the pipeline | Week 4 |
| Deliverables | One-page threat model and a red-team exercise | Week 5 |

## Left out on purpose

A real client deployment would add these. They are outside the budget for this project.

- **Conditional Access.** Needs an Entra ID P1 licence; security defaults are used instead.
- **Private network endpoints.**
- **Outbound allow-lists.**
