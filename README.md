# LLM Harness Skills

A superpower-like skill pack for coding agents working with the LLM Harness framework family.

This repository keeps shared framework knowledge separate from agent-specific exports. Codex is the first supported export target. Claude and other agent formats can be added later without rewriting the core references.

## Covered Frameworks

- `llm-api-adapter`: provider adapter layer for OpenAI, Anthropic, DeepSeek, and OpenAI-compatible endpoints.
- `llm-harness-core`: core agent framework with messages, tools, execution envs, hooks, events, `Agent`, `AgentHarness`, sessions, compaction, and skills/templates.
- `llm-harness-runtime`: runtime v0.2 platform workspace with sandbox, tool registry/source discovery, MCP adapters, resource injection, prompt sources, task lifecycle, sub-agents, tracing, audit, auth, budget, and human approval infrastructure.

## Repository Layout

```text
specs/
  framework-inventory.md
  skill-pack-design.md
shared/
  references/
    architecture.md
    provider-integration.md
    agent-harness-patterns.md
    tool-authoring.md
    runtime-hooks.md
    testing-patterns.md
    anti-patterns.md
codex/
  skills/
    llm-harness-framework/
      SKILL.md
      agents/openai.yaml
      references/*.md
scripts/
  validate.ps1
  sync-codex-skill.ps1
```

`shared/references` is the source of truth. `codex/skills/llm-harness-framework` is the Codex export.

## Codex Skill

The first Codex skill is:

```text
llm-harness-framework
```

Use it when working on provider integration, DeepSeek/OpenAI/Anthropic switching, `Agent`/`AgentHarness`, runtime platform services, tools, hooks, events, sessions, compaction, sandboxing, MCP, task lifecycle, tracing, audit, budget, auth, approval, or tests for the LLM Harness framework family.

## Install For Codex

Install the Codex export by placing this directory in your Codex skills directory:

```text
codex/skills/llm-harness-framework
```

Codex loads personal skills from:

- Windows: `%USERPROFILE%\.codex\skills`
- Linux/macOS: `~/.codex/skills`
- If `CODEX_HOME` is set: `$CODEX_HOME/skills` or `%CODEX_HOME%\skills`

Restart Codex or open a new Codex session after installing.

### Windows: Copy Install

From PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.codex\skills | Out-Null

Copy-Item -Recurse -Force `
  D:\GKXTwork\llm-harness-skills\codex\skills\llm-harness-framework `
  $env:USERPROFILE\.codex\skills\llm-harness-framework
```

If `CODEX_HOME` is set:

```powershell
New-Item -ItemType Directory -Force -Path $env:CODEX_HOME\skills | Out-Null

Copy-Item -Recurse -Force `
  D:\GKXTwork\llm-harness-skills\codex\skills\llm-harness-framework `
  $env:CODEX_HOME\skills\llm-harness-framework
```

### Windows: Development Link

Use a directory junction if you want Codex to read the skill directly from this repository:

```powershell
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.codex\skills | Out-Null

cmd /c mklink /J "%USERPROFILE%\.codex\skills\llm-harness-framework" "D:\GKXTwork\llm-harness-skills\codex\skills\llm-harness-framework"
```

If the target already exists, remove it first or choose copy install.

### Linux/macOS: Copy Install

Replace `/path/to/llm-harness-skills` with your local clone path:

```bash
mkdir -p ~/.codex/skills

cp -R \
  /path/to/llm-harness-skills/codex/skills/llm-harness-framework \
  ~/.codex/skills/llm-harness-framework
```

If `CODEX_HOME` is set:

```bash
mkdir -p "$CODEX_HOME/skills"

cp -R \
  /path/to/llm-harness-skills/codex/skills/llm-harness-framework \
  "$CODEX_HOME/skills/llm-harness-framework"
```

### Linux/macOS: Development Symlink

Use a symlink if you want edits in this repository to apply immediately:

```bash
mkdir -p ~/.codex/skills

ln -sfn \
  /path/to/llm-harness-skills/codex/skills/llm-harness-framework \
  ~/.codex/skills/llm-harness-framework
```

If `CODEX_HOME` is set:

```bash
mkdir -p "$CODEX_HOME/skills"

ln -sfn \
  /path/to/llm-harness-skills/codex/skills/llm-harness-framework \
  "$CODEX_HOME/skills/llm-harness-framework"
```

### Verify Installation

Windows:

```powershell
Get-ChildItem $env:USERPROFILE\.codex\skills\llm-harness-framework
```

Linux/macOS:

```bash
ls ~/.codex/skills/llm-harness-framework
```

The installed skill should contain:

```text
SKILL.md
agents/
references/
```

After opening a new Codex session, you can explicitly invoke it with:

```text
Use $llm-harness-framework to refactor this agent provider integration.
```

## Sync Codex Export

After editing shared references, run:

```powershell
.\scripts\sync-codex-skill.ps1
```

Then validate:

```powershell
.\scripts\validate.ps1
```

If you installed by copy, copy the updated `codex/skills/llm-harness-framework` directory into your Codex skills directory again. If you installed by symlink or junction, no copy step is needed.

## Design Notes

Start with one Codex skill and route to references through progressive disclosure. Split into multiple skills later only if real use shows that the single skill is too broad or loads too much context.

Avoid calling this an SDK-only pack. The main target is an agent framework: provider adapters, harness loop, tools, hooks, runtime platform wiring, and product-agent architecture.
