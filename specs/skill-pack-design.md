# LLM Harness Skill Pack Design

## Goal

Create a superpower-like skill pack that teaches coding agents how to develop against the LLM Harness framework family. Codex is the first export target, but shared content should be usable by Claude and other coding agents later.

## Naming

Use `llm-harness-framework` for the first Codex skill. Avoid `sdk` in the name because the primary target is an agent framework, not just a client SDK.

## Repository Shape

```text
llm-harness-skills/
  README.md
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
        agents/
          openai.yaml
        references/
          architecture.md
          provider-integration.md
          agent-harness-patterns.md
          tool-authoring.md
          runtime-hooks.md
          testing-patterns.md
          anti-patterns.md
  claude/
    README.md
  scripts/
    validate.ps1
    sync-codex-skill.ps1
```

The `shared/` directory is the source of truth. The `codex/` directory is an agent-specific export.

## First Version Scope

Start with one Codex skill:

```text
llm-harness-framework
```

Do not split into multiple skills initially. Use progressive disclosure through reference files. Split later only if real usage shows the skill triggers too broadly or loads too much context.

## Codex Skill Trigger

The Codex skill should trigger when a task involves any of these:

- `llm_adapter`, `llm-api-adapter`, provider integration, OpenAI-compatible endpoints, DeepSeek, Anthropic, OpenAI providers.
- `llm_harness_core`, `llm-harness-core`, `Agent`, `AgentHarness`, `agent_loop`, `HarnessHooks`, `AgentHarnessEvent`.
- `llm_harness_runtime`, `CodingAgentBuilder`, built-in tools, runtime settings, sessions, compaction, auth, budget, audit, or sandboxing.
- Adding an agent tool, hook, provider factory, streaming UI, session-backed agent, or coding-agent runtime integration.

## SKILL.md Responsibilities

Keep `SKILL.md` short. It should instruct the agent to:

1. Inspect the target repository first.
2. Identify which layer the task touches: adapter, core, runtime, or product agent.
3. Load only the relevant reference files.
4. Preserve framework boundaries.
5. Prefer existing framework types and builders over ad hoc implementations.
6. Verify with focused Rust tests or examples.

## Reference Routing

Use these reference files:

- `architecture.md`: layer boundaries, crate responsibilities, when to use `Agent`, `AgentHarness`, or runtime builder.
- `provider-integration.md`: `Provider`, `LlmClient`, DeepSeek, OpenAI-compatible endpoints, provider factories, native vs universal path.
- `agent-harness-patterns.md`: `AgentHarnessOptions`, event subscription, prompt lifecycle, sessions, compaction, skills/templates.
- `tool-authoring.md`: implementing `Tool`, schemas, `ToolContext`, `ToolResult`, execution modes, env access, tool tests.
- `runtime-hooks.md`: `HarnessHooks`, auth, budget, audit, approval, replan, prepare-next-turn, should-stop, provider response hooks.
- `testing-patterns.md`: mock clients, offline adapter fixtures, integration-test gating, event-loop assertions.
- `anti-patterns.md`: known mistakes and architecture violations.

## Design Rules For Agent Users

- Do not bypass `llm_adapter` by hand-writing provider HTTP clients unless the task is explicitly to add a provider to the adapter crate.
- Do not put provider-specific logic in tools.
- Do not put tool execution logic in provider adapters.
- Do not use runtime `CodingAgentBuilder` when a product needs a custom domain runtime unless the coding-agent shape is intentional.
- Do not hardcode one provider in business flows when a provider factory is feasible.
- Do not read environment variables at every call site; centralize configuration.
- Do not ignore stream termination events. Consumers should wait for `Settled`, `Aborted`, `AgentEnd`, or idle state depending on the layer.
- Do not send UI/audit-only data back to the LLM; put it in `ToolResult.details` or harness/runtime side channels.

## First Codex Skill Contents

The first Codex export should contain:

```text
codex/skills/llm-harness-framework/SKILL.md
codex/skills/llm-harness-framework/agents/openai.yaml
codex/skills/llm-harness-framework/references/architecture.md
codex/skills/llm-harness-framework/references/provider-integration.md
codex/skills/llm-harness-framework/references/agent-harness-patterns.md
codex/skills/llm-harness-framework/references/tool-authoring.md
codex/skills/llm-harness-framework/references/runtime-hooks.md
codex/skills/llm-harness-framework/references/testing-patterns.md
codex/skills/llm-harness-framework/references/anti-patterns.md
```

No scripts are required for the first version. Add scripts only after repeated manual work appears, such as API inventory extraction or export synchronization.

## Validation Plan

For the first Codex skill:

1. Run the Codex skill validator on the generated skill directory.
2. Forward-test on these tasks:
   - Refactor an Anthropic-hardcoded agent to support DeepSeek through `llm_adapter::deepseek::client`.
   - Add a new domain tool implementing `Tool`.
   - Add a `BeforeToolCallHook` approval policy.
   - Wire a WebSocket UI to `AgentHarnessEvent` correctly.
3. Revise references based on observed mistakes.

## Later Multi-Agent Exports

After the Codex skill is stable, add adapters for other agents. Keep the shared references as canonical and generate agent-specific wrappers from shared content.

Potential exports:

- Claude: project memory / slash-command style docs.
- Cursor/Cline/Continue: rule files and command snippets.
- Generic Markdown: installable knowledge pack.

Avoid making another agent's format the source of truth.
