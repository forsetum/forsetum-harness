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

Forsetum is a framework for thinking and working; it does not override human
intent or approved scope. In a brownfield project, existing code,
configuration, data, and documented existing behavior are the factual
baseline. Forsetum templates
and tools are canonical only for behavior they generate, not for the target
project's facts. Without explicit `FULL_ALLOW` for a bounded scope, the agent
must obtain human approval before changing the target. Within that scope, it
may decide routine, non-destructive changes using secure-first and minimum
changes. Destructive actions always require explicit human approval for the
specific action. This approval gate applies before the affected target is
mutated.

An agent should pause when a decision is unresolved or a readiness blocker
prevents safe progress. Completion means the requested outcome and evidence
exist; passing a gate alone is not completion.
