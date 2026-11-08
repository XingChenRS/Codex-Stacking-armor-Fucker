# Install the base-instruction override and the developer precedence line into a Codex config.
[CmdletBinding()]
param([string]$CodexHome)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$promptPath = Join-Path $root 'instructions.md'
$developerPath = Join-Path $root 'developer-instructions.txt'
foreach ($file in @($promptPath, $developerPath)) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing file: $file" }
}

if (-not $CodexHome) { $CodexHome = $env:CODEX_HOME }
if (-not $CodexHome) {
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { throw 'Cannot locate the home directory.' }
    $CodexHome = Join-Path $homeDir '.codex'
}
$config = Join-Path $CodexHome 'config.toml'
if (-not (Test-Path -LiteralPath $config)) { throw "config.toml not found: $config" }

$developer = (Get-Content -LiteralPath $developerPath -Raw).Trim()
if ($developer.Contains("'''")) { throw "developer-instructions.txt must not contain '''." }

$lines = [System.IO.File]::ReadAllLines($config)
$firstTable = 0
while ($firstTable -lt $lines.Count -and -not $lines[$firstTable].TrimStart().StartsWith('[')) { $firstTable++ }

$kept = New-Object System.Collections.Generic.List[string]
$i = 0
while ($i -lt $firstTable) {
    $line = $lines[$i]
    $trim = $line.Trim()
    if ($trim -match '^#\s*Codex prompt overrides') { $i++; continue }
    if ($trim -match '^model_instructions_file\s*=') { $i++; continue }
    if ($trim -match '^developer_instructions\s*=') {
        $i++
        if ($trim.Contains("'''")) {
            while ($i -lt $firstTable -and $lines[$i].Trim() -ne "'''") { $i++ }
            if ($i -lt $firstTable) { $i++ }
        }
        continue
    }
    $kept.Add($line)
    $i++
}
for (; $i -lt $lines.Count; $i++) { $kept.Add($lines[$i]) }

$escapedPrompt = $promptPath.Replace('\', '\\').Replace('"', '\"')
$block = @(
    '# Codex prompt overrides (installed by install.ps1)',
    "model_instructions_file = `"$escapedPrompt`"",
    "developer_instructions = '''",
    $developer,
    "'''"
)
$insertAt = 0
while ($insertAt -lt $kept.Count -and -not $kept[$insertAt].TrimStart().StartsWith('[')) { $insertAt++ }
$out = New-Object System.Collections.Generic.List[string]
for ($j = 0; $j -lt $insertAt; $j++) { $out.Add($kept[$j]) }
foreach ($b in $block) { $out.Add($b) }
for ($j = $insertAt; $j -lt $kept.Count; $j++) { $out.Add($kept[$j]) }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$config.bak-$stamp"
Copy-Item -LiteralPath $config -Destination $backup
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($config, (($out -join "`n") + "`n"), $utf8)

$text = [System.IO.File]::ReadAllText($config)
$modelCount = ([regex]::Matches($text, '(?m)^model_instructions_file\s*=')).Count
$devCount = ([regex]::Matches($text, '(?m)^developer_instructions\s*=')).Count
if ($modelCount -ne 1 -or $devCount -ne 1) { throw "Verification failed: model=$modelCount developer=$devCount" }

Write-Host 'Installed.'
Write-Host "  config: $config"
Write-Host "  backup: $backup"
Write-Host "  prompt: $promptPath"
Write-Host 'Restart Codex completely, including the tray process, then open a new session.'
