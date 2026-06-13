---
name: llm-harness-framework
description: "Use when Codex is working with the llm-harness framework family: llm_adapter / llm-api-adapter provider integrations, DeepSeek/OpenAI/Anthropic provider switching, llm_harness_core Agent or AgentHarness code, llm_harness_runtime v0.2 platform services, custom Tool implementations, ToolRegistry/ToolSource, Sandbox, MCP, ResourceProvider, PromptSource, TaskRunner, SubAgentSpawner, TraceExporter, AuditSink, AuthHook, BudgetControlAdapter, HumanApprovalWrapper, HarnessHooks, agent event streaming, sessions, compaction, or tests for these Rust crates."
---

# LLM Harness Framework

Use this skill to make framework-aligned changes in projects built on `llm-api-adapter`, `llm-harness-core`, and `llm-harness-runtime`.

## Workflow

1. Inspect the target repository before editing. Identify whether the task touches adapter, core, runtime, or product-agent code.
2. Load only the reference files needed for the task.
3. Preserve layer boundaries. Prefer existing framework traits, builders, hooks, and event types over ad hoc implementations.
4. Keep provider construction, tool behavior, hook policy, and product workflow separated.
5. Verify with focused Rust tests or examples before broad workspace tests.

## Reference Routing

Read `references/architecture.md` when deciding where a change belongs, or whether to use `Agent`, `AgentHarness`, or runtime v0.2 platform services.

Read `references/provider-integration.md` for `llm_adapter`, `LlmClient`, DeepSeek, OpenAI-compatible endpoints, provider factories, or provider switching.

Read `references/agent-harness-patterns.md` for `AgentHarnessOptions`, sessions, compaction, skill/template loading, event subscription, streaming UI, or prompt lifecycle.

Read `references/tool-authoring.md` when adding or modifying tools that implement `llm_harness_types::Tool`.

Read `references/runtime-hooks.md` for `HarnessHooks`, auth, approval, budget, audit, tracing, replan, phase control, provider response hooks, compaction hooks, or runtime hook adapters.

Read `references/testing-patterns.md` when adding or fixing tests around providers, loops, tools, hooks, runtime builders, or real API integration tests.

Read `references/anti-patterns.md` before finalizing substantial changes, especially provider refactors or agent-loop rewrites.

## Default Decisions

Use `llm_adapter` for provider API access. Do not hand-write provider HTTP clients in product-agent code unless the task is to add adapter support.

Use `Arc<dyn llm_harness_loop::LlmClient>` as the provider boundary for core and product-agent integrations.

Use `llm_adapter::deepseek::client(api_key)` for DeepSeek unless the task explicitly needs a custom OpenAI-compatible base URL/path.

Use `AgentHarness` for product-facing agents that need sessions, hooks, skills, compaction, or rich events. Use `Agent` only for lightweight in-memory agents.

Implement cross-cutting policy with hooks. Implement domain actions with tools. Keep provider selection outside tools.
