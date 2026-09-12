# Governance Workflow

The canonical workflow is:

```text
Understand → Analyze → Discover → Ask Decisions → Readiness Gate
→ Plan → Implement → Verify → Document
```

| Stage | Purpose | Expected output |
|---|---|---|
| Understand | Frame the request and success condition | Scope and known context |
| Analyze | Inspect the existing project | Constraints and affected areas |
| Discover | Find missing facts | Evidence and open questions |
| Ask Decisions | Resolve choices with the human | Recorded decisions |
| Readiness Gate | Check required conditions | Ready state or blockers |
| Plan | Describe the approved work | Reviewable implementation plan |
| Implement | Make approved changes | Updated project artifacts |
| Verify | Test outcomes and invariants | Verification evidence |
| Document | Record what changed and remains | Durable handoff |

The No-Invention Rule prohibits an agent from fabricating architecture,
requirements, or facts. Human decisions are authoritative. The Adaptive
Readiness Gate selects relevant requirements by module and domain rather than
forcing every project through unrelated checks.

An agent should pause when a decision is unresolved or a readiness blocker
prevents safe progress. Completion means the requested outcome and evidence
exist; passing a gate alone is not completion.
