# Security Setup — Day 1

**Date:** 2026-11-14  
**Directory:** ClaimPilot (personal Azure tenant)  

## Identity & Access

- **MFA on personal admin account:** Microsoft Authenticator registered on the primary Microsoft account; passkey added as a second factor. Recovery code stored offline in password manager.
- **Security Defaults:** Enabled in Entra ID. Requires all directory users to register Authenticator within 14 days. Blocks legacy sign-in methods that cannot perform MFA. Azure portal enforces MFA separately.
- **Emergency Global Admin:** `breakglass@<tenant>.onmicrosoft.com` created with Global Administrator role, Authenticator registered, credentials stored offline.

## Infrastructure & Compliance

- **Region:** East US 2 (US-only, required for privacy controls).
- **Budget Alert:** $100/month with alerts at 50%, 80%, 100% (Actual) and 100% (Forecasted), sent to personal email.
- **Resource Group:** `rg-claimpilot-dev` with tags `project=claimpilot`, `env=dev`, `owner=personal`.

## Secrets & Configuration

- All secrets held in Azure Key Vault (created week 2). No secrets in code, environment files, or logs.
- Prompt injection: Claim loss descriptions and police reports treated as data, never as instructions.
- Content filtering: Azure Content Safety will screen model outputs before adjuster display.

## Audit & Logging

- Foundry tracing enabled; traces retained 30 days, then deleted.
- Personal data redacted before any log or evaluation dataset.
- Every recommendation, adjuster approval, edit and rejection recorded in claims API audit table.

## Left Out (Production-Ready Addition)

- **Conditional Access:** Requires Entra ID P1 license. Not implemented for personal project.
- **Private Network Endpoints:** Not needed for development; production deployment would add them.
- **Outbound Allow-Lists:** Not configured for development; production would restrict egress to known addresses.

## Week 5 Deliverables

See the project plan for the threat model and red-team exercise scope.
