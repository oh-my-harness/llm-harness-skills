$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$skill = Join-Path $root "codex\skills\llm-harness-framework"
$validator = Join-Path $env:USERPROFILE ".codex\skills\.system\skill-creator\scripts\quick_validate.py"

if (-not (Test-Path -LiteralPath $skill)) {
    throw "Missing Codex skill directory: $skill"
}
if (-not (Test-Path -LiteralPath $validator)) {
    throw "Missing Codex skill validator: $validator"
}

python $validator $skill
