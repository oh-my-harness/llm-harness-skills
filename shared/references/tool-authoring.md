# Tool Authoring

Use this reference when adding or modifying tools for agents built on `llm-harness-core`.

## Trait

Implement `llm_harness_types::Tool`:

```rust
pub trait Tool: Send + Sync {
    fn name(&self) -> &str;
    fn label(&self) -> &str { self.name() }
    fn description(&self) -> &str;
    fn parameters_schema(&self) -> &serde_json::Value;
    fn execution_mode(&self) -> ToolExecutionMode { ToolExecutionMode::Parallel }
    fn prepare_arguments(&self, raw: serde_json::Value) -> Result<serde_json::Value, ToolError> { Ok(raw) }
    fn execute<'a>(&'a self, args: serde_json::Value, ctx: &'a ToolContext) -> BoxFuture<'a, Result<ToolResult, ToolError>>;
}
```

## Schema

Expose a stable tool name and a JSON Schema object. Keep names stable because they appear in LLM tool definitions and session logs.

Validate required parameters explicitly in `execute` or normalize them in `prepare_arguments`.

## Execution Environment

Use `ctx.env` for filesystem and shell work:

- `read_text_file`
- `read_text_lines`
- `read_binary_file`
- `write_file`
- `append_file`
- `file_info`
- `list_dir`
- `exists`
- `create_dir`
- `remove`
- `create_temp_dir`
- `execute_shell`

Respect `ctx.abort` for cancellable operations. Pass it through to `ExecutionEnv` methods.

Avoid direct `std::fs` or shell process calls in tools unless the tool is intentionally local-only and the tradeoff is explicit.

## ToolResult

`ToolResult.content` is sent back to the LLM.

`ToolResult.details` is not sent to the LLM. Use it for UI, audit, diagnostics, raw metadata, or structured render data.

`ToolResult.terminate` requests early loop termination when all tools in the batch return `terminate = true`.

## Intermediate Updates

Long-running tools can send partial results through `ctx.update_tx`. These become `AgentEvent::ToolExecutionUpdate`.

Use updates for progress that should be observed by UI but does not need to be final tool output.

## Execution Mode

Default mode is `Parallel`. Use `Sequential` when the tool must form a boundary in a batch, such as stateful edits, unsafe operations, or operations that should not overlap with other tools.

## Error Classification

Use `ToolError::InvalidArguments` for malformed or missing arguments.

Use execution errors for environment failures, command failures that should be treated as tool failures, parse failures, or domain failures.

Do not panic on bad model arguments.

## Testing

Test tools with mock or real `ExecutionEnv` implementations. Assert:

- schema is stable
- missing arguments return invalid-argument errors
- successful execution returns content and details as expected
- cancellation is propagated where relevant
- filesystem/shell operations go through `ExecutionEnv`

## Common Mistakes

Do not call an LLM from inside a tool unless the tool's domain purpose is explicitly an LLM-backed tool.

Do not put provider selection or model names inside tools.

Do not put UI-only data in `content`; use `details`.

Do not assume a local OS environment. Tools should work with any `ExecutionEnv` that supports their required operations.
