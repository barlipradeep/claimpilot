# ADR-001: Microsoft-Native Stack

**Status:** Accepted  
**Date:** 2026-11-14  

## Context

ClaimPilot is a side project to build hands-on experience with Azure AI Foundry and related Microsoft services. Hands-on Foundry experience is a hard requirement in Microsoft-practice forward-deployed engineer roles. All data is synthetic or public.

## Decision

Build the entire stack on Microsoft technologies:
- **Orchestration:** Azure AI Foundry Agent Service and Microsoft Agent Framework
- **Models:** A small model for extraction and a larger one for coverage reasoning, both deployed through Foundry with pinned versions. The specific models are not yet chosen and will be recorded in a later ADR.
- **Data & Storage:** Azure SQL, Azure Service Bus, Azure Document Intelligence, Azure AI Search
- **Infrastructure:** Bicep, Azure Container Apps, Azure Key Vault
- **CI/CD:** GitHub Actions
- **Observability:** Foundry tracing, Application Insights

## Consequences

**Benefits:**
- Hands-on depth with Foundry: deployments, evaluations, tracing, agentic patterns
- Production-ready integration patterns (identity, secrets, observability, security)
- Transferable experience directly to client work in Azure environments

**Trade-offs:**
- Vendor lock-in to Azure (accepted on purpose)
- Some services are newer (Agent Service, Foundry IQ) with evolving APIs
- Slightly higher operational complexity than a fully managed solution

## Notes

Policy form retrieval uses Azure AI Search directly, starting on the Free tier. Foundry IQ is a managed layer built on Azure AI Search's agentic retrieval; whether to adopt it is undecided and will be revisited once the core agent works in week 3.
