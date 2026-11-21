<#
.SYNOPSIS
    Saves a Claude Code session transcript as Markdown in docs/session-logs/.

.DESCRIPTION
    Runs automatically from the SessionEnd hook in .claude/settings.json, which
    passes the session details as JSON on standard input.

    Can also be run by hand:
        .\scripts\save-session.ps1                               # newest session for this project
        .\scripts\save-session.ps1 -TranscriptPath <file.jsonl>  # a specific session

    The file is named after the session's start time and the first 8 characters
    of its ID, e.g. 2026-11-14-1725-session-f0dd9965.md, so saving the same
    session again overwrites its file instead of creating a duplicate.
#>
param(
    [string]$TranscriptPath
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path (Join-Path $projectRoot 'docs') 'session-logs'
$sessionId = $null
$reason = 'manual'

# 1. Work out which transcript to save.
if (-not $TranscriptPath -and [Console]::IsInputRedirected) {
    $raw = [Console]::In.ReadToEnd()
    if ($raw -and $raw.Trim()) {
        $hookInput = $raw | ConvertFrom-Json
        $TranscriptPath = $hookInput.transcript_path
        $sessionId = $hookInput.session_id
        if ($hookInput.reason) { $reason = $hookInput.reason }
    }
}

if (-not $TranscriptPath) {
    # Claude Code stores transcripts under ~/.claude/projects/<project path with non-alphanumerics as dashes>/
    $key = $projectRoot -replace '[^A-Za-z0-9]', '-'
    $dir = Join-Path $env:USERPROFILE ".claude\projects\$key"
    if (-not (Test-Path -LiteralPath $dir)) { throw "No transcript folder for this project: $dir" }
    $latest = Get-ChildItem -LiteralPath $dir -Filter '*.jsonl' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "No transcripts found in $dir" }
    $TranscriptPath = $latest.FullName
}

if (-not (Test-Path -LiteralPath $TranscriptPath)) { throw "Transcript not found: $TranscriptPath" }
if (-not $sessionId) { $sessionId = [IO.Path]::GetFileNameWithoutExtension($TranscriptPath) }

# 2. Turn the JSONL transcript into Markdown: user and Claude text only.
$body = New-Object System.Collections.Generic.List[string]
$firstTime = $null
$lastTime = $null
$prevRole = $null
$turns = 0

foreach ($line in [IO.File]::ReadLines($TranscriptPath, [Text.Encoding]::UTF8)) {
    if (-not $line.Trim()) { continue }
    try { $entry = $line | ConvertFrom-Json } catch { continue }
    if ($entry.type -ne 'user' -and $entry.type -ne 'assistant') { continue }
    if ($entry.isMeta -or $entry.isSidechain) { continue }

    if ($entry.timestamp) {
        $t = ([datetime]$entry.timestamp).ToLocalTime()
        if (-not $firstTime) { $firstTime = $t }
        $lastTime = $t
    }

    $content = $entry.message.content
    $parts = @()
    if ($content -is [string]) {
        $parts += $content
    }
    else {
        foreach ($block in $content) {
            if ($block.type -eq 'text') { $parts += $block.text }
            elseif ($block.type -eq 'tool_use') { $parts += "*[Tool: $($block.name)]*" }
            elseif ($block.type -eq 'document') { $parts += '*[Attached document]*' }
        }
    }

    $text = ($parts | Where-Object { $_ -and $_.Trim() }) -join "`n`n"
    $text = [regex]::Replace($text, '(?s)<system-reminder>.*?</system-reminder>', '')
    $text = [regex]::Replace($text, '(?s)<local-command-caveat>.*?</local-command-caveat>', '')
    $text = $text.Trim()
    if (-not $text) { continue }

    $role = if ($entry.type -eq 'user') { 'User' } else { 'Claude' }
    if ($role -ne $prevRole) {
        $body.Add("## $role")
        $body.Add('')
        $prevRole = $role
        $turns++
    }
    $body.Add($text)
    $body.Add('')
}

if ($turns -eq 0) {
    Write-Output "Nothing to save: no conversation text in $TranscriptPath"
    exit 0
}

# 3. Write the file.
if (-not $firstTime) { $firstTime = Get-Date }
$stamp = $firstTime.ToString('yyyy-MM-dd-HHmm')
$shortId = $sessionId.Substring(0, [Math]::Min(8, $sessionId.Length))
$fileName = "$stamp-session-$shortId.md"
$filePath = Join-Path $logDir $fileName

if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }

$header = @(
    "# Session $stamp",
    '',
    "- **Session ID:** $sessionId",
    "- **Started:** $($firstTime.ToString('yyyy-MM-dd HH:mm'))",
    "- **Last message:** $(if ($lastTime) { $lastTime.ToString('yyyy-MM-dd HH:mm') } else { 'unknown' })",
    "- **Saved:** $((Get-Date).ToString('yyyy-MM-dd HH:mm')) ($reason)",
    '',
    '---',
    ''
)

$markdown = (($header + $body) -join "`r`n")
[IO.File]::WriteAllText($filePath, $markdown, (New-Object Text.UTF8Encoding $false))
Write-Output "Saved session to $filePath"
