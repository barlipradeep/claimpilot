# Scripts

## save-session.ps1

Saves a Claude Code session transcript as Markdown in `docs/session-logs/`. That folder is git-ignored, so the logs stay on your machine.

### Automatic

A `SessionEnd` hook in `.claude/settings.json` runs the script when a Claude Code session ends, whether it is closed, cleared or the user logs out. Claude Code passes the transcript location to the script, so nothing needs to be done by hand.

The hook only loads when Claude Code is started in this repository's folder.

### By hand

```powershell
# Save the most recent session started in this project
.\scripts\save-session.ps1

# Save a specific session
.\scripts\save-session.ps1 -TranscriptPath "$env:USERPROFILE\.claude\projects\<project>\<session-id>.jsonl"
```

### Output

One file per session, named after the session's start time and the first 8 characters of its ID:

```
docs/session-logs/2026-11-14-1725-session-f0dd9965.md
```

Saving the same session again overwrites its file, so a resumed session ends up as one complete log.

The file contains what you and Claude wrote. Tool calls appear as one-line markers such as `[Tool: Edit]`, and tool output and system notes are left out.
