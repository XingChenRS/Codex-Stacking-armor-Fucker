# Remove the base-instruction override and the developer precedence line from a Codex config.
[CmdletBinding()]
param([string]$CodexHome)

$ErrorActionPreference = 'Stop'
if (-not $CodexHome) { $CodexHome = $env:CODEX_HOME }
if (-not $CodexHome) {
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { throw 'Cannot locate the home directory.' }
    $CodexHome = Join-Path $homeDir '.codex'
}
$config = Join-Path $CodexHome 'config.toml'
if (-not (Test-Path -LiteralPath $config)) { throw "config.toml not found: $config" }

$lines = [System.IO.File]::ReadAllLines($config)
$firstTable = 0
while ($firstTable -lt $lines.Count -and -not $lines[$firstTable].TrimStart().StartsWith('[')) { $firstTable++ }

$out = New-Object System.Collections.Generic.List[string]
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
    $out.Add($line)
    $i++
}
for (; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$config.bak-$stamp"
Copy-Item -LiteralPath $config -Destination $backup
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($config, (($out -join "`n") + "`n"), $utf8)

$text = [System.IO.File]::ReadAllText($config)
$remaining = ([regex]::Matches($text, '(?m)^(model_instructions_file|developer_instructions)\s*=')).Count
if ($remaining -ne 0) { throw "Verification failed: $remaining override keys remain." }

Write-Host 'Removed.'
Write-Host "  config: $config"
Write-Host "  backup: $backup"
Write-Host 'Restart Codex completely, including the tray process.'
