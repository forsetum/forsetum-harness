# Concepts

- **Context:** Known facts about the project, request, environment, and
  boundaries.
- **Decision:** An authoritative human choice that constrains later work.
- **Constraint:** A rule or limit that work must respect; it is not merely a
  preference.
- **Assumption:** A provisional belief that must be confirmed or explicitly
  accepted as an assumption.
- **Readiness Requirement:** A condition that must be satisfied before the
  next workflow stage.
- **Plan:** An ordered, reviewable description of intended implementation.
- **Verification:** Evidence that an outcome or invariant was checked.
- **Artifact:** A durable output such as a document, script, report, or test.
- **Module:** A domain-specific overlay added to the universal core.
- **Harness:** The governance artifacts and tooling that guide AI-assisted
  work in a target project.
- **Prime rule:** Forsetum provides a framework for decisions; human intent
  and approved scope govern the work. In brownfield projects, existing code,
  configuration, data, and documented existing behavior describe
  the factual system baseline.
  Forsetum templates and tools are canonical for the behavior they generate,
  not for facts about the target project.
- **Bounded `FULL_ALLOW`:** Explicit authority for routine, non-destructive
  decisions within its stated scope. Delegated choices use secure-first,
  minimum changes. Destructive actions always need explicit human approval
  for that action.

Important distinctions:

```text
Fact != Decision
Decision != Assumption
Constraint != Preference
Readiness != Completion
```
