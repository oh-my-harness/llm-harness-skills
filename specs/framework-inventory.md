# LLM Harness Framework Inventory

This inventory summarizes the three framework repositories that the skill pack should teach coding agents to use correctly.

## Repositories

- `D:\GKXTwork\llm-api-adapter`: provider adapter layer. Normalizes provider wire formats into canonical chat, streaming, tool-call, reasoning, usage, and error types.
- `D:\GKXTwork\llm-harness-core`: core agent framework. Owns message/tool/env contracts, streaming loop, `Agent`, `AgentHarness`, sessions, compaction, skills, and events.
- `D:\GKXTwork\llm-harness-runtime`: higher-level runtime wrapper for coding-agent style applications. Owns built-in filesystem/shell tools, prompt assembly, settings, `CodingAgentBuilder`, JSONL sessions, and auto-compaction wiring.

## Layer Boundaries

`llm-api-adapter` is the provider boundary. It should be used through `llm_adapter::Provider` or, from core integrations, `llm_harness_loop::LlmClient`.

`llm-harness-core` is the framework boundary. It should be the default integration layer for agent products. Use `Agent` for lightweight stateful prototypes and `AgentHarness` for session-backed agents, events, hooks, skills, compaction, and branch/session operations.

`llm-harness-runtime` is an application/runtime convenience layer. Use it when building coding-agent style products that want built-in tools, prompt assembly, context-file loading, retry, JSONL session storage, and auto-compaction. Do not assume every domain agent should depend on runtime if it needs a custom runtime shape.

## Provider Integration

The canonical provider trait is `llm_adapter::provider::Provider`.

`llm-harness-loop` re-exports this trait as:

```rust
pub use llm_adapter::provider::Provider as LlmClient;
```

Framework code should pass providers as:

```rust
Arc<dyn LlmClient>
```

DeepSeek is already supported by `llm-api-adapter`:

```rust
use llm_adapter::deepseek;
use llm_harness_loop::LlmClient;

let client = Arc::new(deepseek::client(api_key)) as Arc<dyn LlmClient>;
```

`deepseek::client(api_key)` returns an `OpenAIProvider` preconfigured with:

- `base_url = https://api.deepseek.com`
- `parse_reasoning_content(true)`
- `tolerant_keepalive(true)`
- capabilities: images false, reasoning true, json_schema true

Provider-agnostic code should use the universal `Provider::chat` / `Provider::chat_stream` path. Use provider-native paths only for provider-specific fields such as OpenAI `extra_body`, `reasoning_effort`, Anthropic `thinking`, cache hints, or structured output differences.

## Core Contracts

Important crates in `llm-harness-core`:

- `llm-harness-types`: stable shared contracts for messages, content blocks, tools, execution envs, events, errors, hooks, compaction metadata, stream options, thinking level, and token usage.
- `llm-harness-loop`: low-level streaming agent loop, adapter bridge, retry config, request conversion, and tool dispatch. Most downstream code should not call it directly unless building a custom runtime.
- `llm-harness`: user-facing framework facade with `Agent`, `AgentHarness`, session repositories, compaction, skill/template loading, and prelude exports.

## Agent Choices

Use `Agent` when:

- The workflow is lightweight or prototype-like.
- In-memory transcript is enough.
- Session persistence, branch operations, compaction, skills, and harness-level hooks are not required.

Use `AgentHarness` when:

- The agent is product-facing or long-running.
- It needs session persistence, JSONL/session repos, compaction, skills/templates, event observability, hooks, branch/session operations, or externally visible lifecycle state.

Use `CodingAgentBuilder` from runtime when:

- The product is close to a coding agent.
- It should use built-in read/bash/edit/write/grep/find/ls tools.
- It should assemble a coding-agent system prompt, load AGENTS.md/CLAUDE.md context files, load skills/templates, persist sessions, retry transient errors, and auto-compact.

## Tool Contract

Custom tools implement `llm_harness_types::Tool`:

```rust
fn name(&self) -> &str;
fn description(&self) -> &str;
fn parameters_schema(&self) -> &serde_json::Value;
fn execution_mode(&self) -> ToolExecutionMode { ToolExecutionMode::Parallel }
fn prepare_arguments(&self, raw: serde_json::Value) -> Result<serde_json::Value, ToolError>;
fn execute<'a>(&'a self, args: serde_json::Value, ctx: &'a ToolContext) -> BoxFuture<'a, Result<ToolResult, ToolError>>;
```

`ToolResult.content` is sent back to the LLM. `ToolResult.details` is structured side-channel data for UI, audit, or diagnostics. `ToolResult.terminate` allows early loop termination when all tools in a batch request termination.

Tools should use `ToolContext.env` for filesystem/shell operations, not direct local IO, when portability or sandboxing matters.

## Execution Environment

`ExecutionEnv` abstracts filesystem and shell access. Implementations may represent local OS, containers, remote machines, WASM sandboxes, or test mocks.

Use `UnsupportedEnv` for agents without tool environment access. Use runtime `OsEnv` for local coding-agent workflows.

## Hooks

`HarnessHooks` supports:

- `before_run`, `before_turn`, `after_turn`
- `before_tool_call`, `after_tool_call`
- `transform_context`
- `prepare_next_turn`
- `should_stop`
- `before_provider_request`, `after_provider_response`
- `before_compact`

Use hooks for cross-cutting behavior such as approval, budget, audit, context transforms, replan policies, phase management, dynamic active-tool selection, and provider response accounting. Avoid embedding these concerns directly inside tools or provider code.

## Events

Core `AgentEvent` includes lifecycle, turn, message, token, tool-call, tool-execution, and error events.

`AgentHarnessEvent` wraps raw `AgentEvent` and adds harness-level events such as phase changes, model/tool/resource updates, compaction start/end, queue updates, save points, branches, tool call start/end, `Settled`, and `Aborted`.

UI and streaming integrations should subscribe before prompting and consume events until `Settled`, `Aborted`, `AgentEnd`, or the relevant idle condition.

## Runtime Layer

`llm-harness-runtime` currently exposes:

- `CodingAgent` and `CodingAgentBuilder`
- built-in tools: `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls`
- default active tools: `read`, `bash`, `edit`, `write`
- settings merge: global settings plus project `.coding-agent/settings.json`
- system prompt assembly with tools, context files, skills, custom prompt, appended prompt, and guidelines
- session persistence through `JsonlSessionRepo`
- auto-compaction after prompts

## High-Value Skill Coverage

The skill pack should help agents with:

- Adding or switching LLM providers without bypassing `LlmClient`.
- Refactoring hardcoded Anthropic/OpenAI code into provider factories.
- Authoring correct `Tool` implementations.
- Wiring `AgentHarnessOptions`, `HarnessHooks`, and event loops.
- Choosing `Agent`, `AgentHarness`, or runtime `CodingAgentBuilder`.
- Testing with mock clients and offline provider fixtures.
- Avoiding architecture drift across adapter/core/runtime boundaries.
