# FAQ

## Is Forsetum an AI model?

No. It is a local governance harness and template/tooling library used with an
AI agent or coding assistant.

## Does it require an API key or Forsetum Cloud?

No for the documented core local usage. The public Harness does not require a
Forsetum account or API key.

## Does it work offline?

The local scripts and templates do not require network access after the source
repository is retrieved. The selected AI agent may have separate requirements.

## Does it replace AGENTS.md?

No. It generates and uses `AGENTS.md` as one part of a broader governance
artifact set.

## Does it work with existing projects?

Yes. The `app-maintenance` module is intended for brownfield work, and the
initializer accepts a target directory. Review overwrite behavior before
initializing an existing harness.

## Does it only support software development?

No. Modules also cover landing pages, research, content marketing, sales
outreach, and general office operations.

## Can I customize the templates?

Yes. Keep the manifest, variable registries, and bilingual structure aligned
where both languages are maintained, then run the validator.

## Why use readiness gates?

They make missing facts and decisions visible before planning or implementation
and adapt requirements to the selected domain.

## Why not use one large system prompt?

Durable local artifacts make context, decisions, constraints, plans, and
verification reviewable and reusable across tools and sessions.
