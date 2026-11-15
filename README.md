# ClaimPilot

An AI agent that reads auto insurance claims and recommends the appropriate adjuster queue, approved by a human reviewer.

## Overview

ClaimPilot is a six-week project to build hands-on experience with Azure AI Foundry in a production-grade system. It demonstrates:

- Agentic retrieval and tool use in Azure AI Foundry
- Evaluation pipelines and quality gates
- Production observability with Foundry tracing and Application Insights
- Enterprise integration patterns (identity, secrets, audit)
- Security and safety guardrails

All data is synthetic or public.

## Quick Start

See the [project plan](docs/) for the full scope, architecture, and six-week plan.

### Prerequisites

- Azure subscription (personal or isolated tenant)
- .NET 8 SDK
- Python 3.11+
- Bicep CLI

### Folders

- `/infra` — Bicep infrastructure code
- `/api` — .NET claims API and adjuster screen
- `/agent` — Python agent for triage recommendations
- `/eval` — Golden set and evaluation pipelines
- `/docs` — Architecture decisions (ADR), security notes, results

## Development

Week-by-week setup instructions are in the project plan. Start with week 1 discovery and framing.

## Security

See [security-setup.md](docs/security-setup.md) for identity, MFA, and audit configuration. Week 5 includes a threat model and red-team exercise.

## Results

Results, metrics and tester feedback will be published here on completion.

---

**Status:** Week 1 — Discovery & Framing  
**Last Updated:** 2026-11-14
