# Quickstart Guide: Working with AI IDEs

> Welcome to your AI Agent Harness! This guide gets you up and running with your favorite AI coding tool in under 5 minutes.

---

## 1. Supported AI Environments

This harness is designed to work seamlessly with modern AI agent tools and IDEs:
- **Google Antigravity / Antigravity IDE**
- **Cursor**
- **VS Code** (with GitHub Copilot, Roo Code, Cline, or Continue)
- **Claude Code** (CLI)
- **Windsurf** / **Hermes Agent**

---

## 2. 5-Minute Setup

### Step 1: Open the Project in Your AI IDE
Open this directory as your root workspace in your AI editor or terminal.

### Step 2: Kick off the AI Agent
Start a new chat session with your AI agent and use the following opening prompt:

```text
Please read AGENTS.md and docs/INDEX.md thoroughly.
Review the current readiness status in docs/09-governance/implementation-readiness.md.
Acknowledge the rules and ask me which feature or backlog task we should work on first.
```

### Step 3: Customize Project Variables (Optional)
This template uses `{{...}}` placeholders so you can define your project details. You can either:
- Run search-and-replace across the workspace for placeholder variables (e.g. `{{PROJECT_NAME}}` and domain variables).
- Or simply ask your AI agent: *"Please replace {{PROJECT_NAME}} with 'My Awesome App' and update variables across docs."*

---

## 3. Best Practices for High-Quality Code

1. **Keep Documentation in Sync**: Whenever the AI modifies architecture or adds API routes, ask it to update the corresponding files under `docs/`.
2. **Follow Test-Driven Development (TDD)**: Ask your AI agent to write tests before implementing business logic.
3. **Check Implementation Readiness**: Verify that requirements are clear before asking the agent to generate large chunks of code.

---

## 4. Need More Tailored or Enterprise Harnesses?

This starter harness provides core foundational governance for web applications.

If you need deeper, production-grade harnesses with enterprise specifications, visit our **AI Harness Generator**:
- **Enterprise Web Fullstack**: Microservices, database schema, API contracts, DR plans, and monitoring.
- **High-Converting Landing Page**: Section wireframes, copywriting formulas, SEO clusters, and analytics.
- **B2B Sales & Outreach**: ICP definitions, objection handling scripts, and CRM pipelines.
- **Mobile Application**: Offline sync, biometric permissions, and App Store guidelines.
- **CLI & Automation**: Deterministic exit codes, systemd/cron daemons, and batch processing.

👉 **Generate your next harness:** Check your email receipt or visit the generator portal to unlock advanced presets.
