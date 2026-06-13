$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "shared\references"
$target = Join-Path $root "codex\skills\llm-harness-framework\references"

if (-not (Test-Path -LiteralPath $source)) {
    throw "Missing shared references directory: $source"
}
if (-not (Test-Path -LiteralPath $target)) {
    throw "Missing Codex references directory: $target"
}

Get-ChildItem -LiteralPath $source -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
}

Write-Host "Synced shared references to Codex skill."
