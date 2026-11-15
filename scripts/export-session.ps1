#Requires -Version 5.0
<#
.SYNOPSIS
    Exports the current Claude Code session to a dated markdown file in docs/session-logs/

.DESCRIPTION
    Saves the current session transcript and metadata to docs/session-logs/ with
    filename format YYYY-MM-DD-HHmm-session.md

.PARAMETER SessionId
    Optional session ID to export. If not provided, uses CLAUDE_SESSION_ID env var.

.PARAMETER IncludeTimestamp
    If true, includes detailed timestamps for each message (default: true)

.EXAMPLE
    PS> .\export-session.ps1
    # Exports current session to docs/session-logs/2026-11-14-1430-session.md

.EXAMPLE
    PS> .\export-session.ps1 -SessionId "abc123def456"
    # Exports specific session

.NOTES
    Author: ClaimPilot Project
    This script is run manually after each session or via Claude Code hooks.
    Sessions are automatically logged at close time; use this for full transcripts.
#>

param(
    [string]$SessionId = $env:CLAUDE_SESSION_ID,
    [bool]$IncludeTimestamp = $true
)

# Configuration
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path (Join-Path $ProjectRoot "docs") "session-logs"
$Timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
$FileName = "$Timestamp-session.md"
$FilePath = Join-Path $LogDir $FileName

# Create directory if it doesn't exist
if (-not (Test-Path $LogDir)) {
    Write-Host "Creating session logs directory: $LogDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
}

# Check if file already exists (same minute)
if (Test-Path $FilePath) {
    Write-Host "Session file already exists for this minute: $FileName" -ForegroundColor Yellow
    Write-Host "A new export in the same minute will overwrite it." -ForegroundColor Yellow
    $response = Read-Host "Continue? (y/n)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Export cancelled." -ForegroundColor Red
        exit 1
    }
}

# Build session metadata
$SessionInfo = @{
    "exportTime" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "sessionId" = if ($SessionId) { $SessionId } else { "unknown" }
    "timestamp" = $Timestamp
    "projectRoot" = $ProjectRoot
}

# Build markdown content
$markdown = @"
# Session Export: $Timestamp

**Exported:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Session ID:** $($SessionInfo.sessionId)

## Session Details

- **Project:** ClaimPilot
- **Export Date:** $(Get-Date -Format 'dddd, MMMM d, yyyy')
- **Export Time:** $(Get-Date -Format 'HH:mm:ss zzz')
- **Project Root:** $ProjectRoot

## Export Instructions

To capture the full session transcript:

1. In Claude Code, go to the session you want to export
2. Select all text (Ctrl+A or Cmd+A)
3. Copy (Ctrl+C or Cmd+C)
4. Paste into this file or a new file in `docs/session-logs/`

### Manual Export via Claude Code

If Claude Code has export functionality:
- Right-click the session → Export as Markdown
- Or use the transcript view to copy content

### Session Content

<!-- Paste full session transcript below this line -->

---
End of exported session.
"@

# Write to file
try {
    $markdown | Out-File -FilePath $FilePath -Encoding UTF8 -Force
    Write-Host "[OK] Session log created: $FileName" -ForegroundColor Green
    Write-Host "     Location: $FilePath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. In Claude Code, copy your full session transcript (Ctrl+A, Ctrl+C)"
    Write-Host "2. Open $FileName in your editor"
    Write-Host "3. Paste the transcript after the 'Session Content' section"
    Write-Host "4. Save and commit to git"
}
catch {
    Write-Host "[ERROR] Error creating session log: $_" -ForegroundColor Red
    exit 1
}
