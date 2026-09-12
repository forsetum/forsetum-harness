# Agent Integration

Forsetum uses a vendor-neutral repository pattern:

1. Initialize the harness.
2. Complete known context.
3. Record decisions.
4. Resolve readiness blockers.
5. Instruct the agent to read `AGENTS.md`.
6. Require planning before implementation.
7. Implement approved changes.
8. Verify the result.
9. Document the outcome.

The same instruction can be used with Claude Code, Cursor, Codex, or another
repository-aware agent. These are usage examples, not vendor integrations or
compatibility guarantees:

```text
Read AGENTS.md and the relevant project docs first. Follow the documented
workflow. Do not invent missing decisions. Show the plan and verification
evidence before declaring the work complete.
```

The harness remains local and tool-agnostic; the selected agent is responsible
for reading the generated artifacts and following their instructions.
