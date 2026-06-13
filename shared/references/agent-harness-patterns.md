# Agent Harness Patterns

Use this reference when building product-facing agents, streaming UIs, session-backed workflows, compaction, skills/templates, or harness event handling.

## Agent vs AgentHarness

`Agent` is a lightweight stateful wrapper around the loop. It maintains an in-memory transcript and emits `AgentEvent`.

`AgentHarness` is the product-facing orchestration layer. It manages sessions, pending writes, compaction, skills/templates, harness lifecycle state, hooks, queues, branch/session operations, and `AgentHarnessEvent`.

Prefer `AgentHarness` when building a real application.

## Minimal Harness

```rust
use std::sync::Arc;
use llm_harness::{AgentHarness, AgentHarnessOptions};
use llm_harness_loop::LlmClient;
use llm_harness_types::ExecutionEnv;

let opts = AgentHarnessOptions::new(model);
let harness = AgentHarness::new_in_memory(
    client as Arc<dyn LlmClient>,
    env as Arc<dyn ExecutionEnv>,
    opts,
).await;
```

## Options

`AgentHarnessOptions` includes:

- `model`
- `model_info`
- `thinking_level`
- `tools`
- `system_prompt`
- `max_tokens`
- `queue_capacity`
- `stream_options`
- `hooks`
- `auth`
- `convert_to_llm`
- `skills`
- `templates`
- `retry`
- compaction reserve/keep-recent overrides

Start with `AgentHarnessOptions::new(model)` and override only the fields needed by the task.

## Event Subscription

Subscribe before calling `prompt` if the caller needs all events from the run:

```rust
let mut rx = harness.subscribe();
harness.prompt(prompt).await?;

while let Ok(event) = rx.recv().await {
    match event.as_ref() {
        AgentHarnessEvent::Agent(agent_event) => {}
        AgentHarnessEvent::Settled | AgentHarnessEvent::Aborted => break,
        _ => {}
    }
}
```

For token streaming, inspect wrapped `AgentEvent::TextDelta` and `AgentEvent::ThinkingDelta`.

For complete assistant output, inspect `AgentEvent::MessageEnd`.

For tool observability, inspect both raw `AgentEvent` tool events and harness-level `ToolCallStart` / `ToolCallEnd`.

## Completion Conditions

Use the correct completion condition for the layer:

- `Agent`: `AgentEvent::AgentEnd` or `agent.wait_for_idle()`.
- `AgentHarness`: `AgentHarnessEvent::Settled`, `AgentHarnessEvent::Aborted`, or `harness.wait_for_idle()`.
- UI event forwarding: keep forwarding until socket close or harness completion.

Do not stop after the first text delta or first message update.

## Sessions

Use `AgentHarness::new_in_memory` for one-shot tests and prototypes.

Use `AgentHarness::with_session` with a `Session` for persistent agents. Runtime `CodingAgentBuilder` can wire `JsonlSessionRepo` automatically when a `session_dir` is supplied.

## Compaction

Harness compaction uses model metadata and compaction settings to decide what to summarize and preserve.

Use `before_compact` hooks for custom compaction policy or externally generated summaries.

Do not implement ad hoc transcript truncation in product code unless intentionally bypassing core compaction.

## Skills And Templates

Use harness skill/template loading when prompt resources should be first-class framework resources.

Runtime `CodingAgentBuilder` can load skill dirs and template dirs during construction, then call `harness.reload_resources(...)`.

## Runtime Mutations

Harness supports updates to model, thinking level, tool list, active tool subset, system prompt, resources, queues, and branches through its API and events.

When changing tools dynamically, prefer `set_tools` or `set_active_tools` instead of filtering inside each tool.
