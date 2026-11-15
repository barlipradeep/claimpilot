# ClaimPilot Scripts

Helper scripts for managing and maintaining the ClaimPilot project.

## Session Export Script

### `export-session.ps1`

Exports Claude Code sessions to dated markdown files for version control and documentation.

**Usage:**

```powershell
# From the scripts directory
.\export-session.ps1

# Or from project root
.\scripts\export-session.ps1

# With specific session ID
.\export-session.ps1 -SessionId "abc123def456"
```

**What it does:**

1. Creates `docs/session-logs/` directory if it doesn't exist
2. Creates a new markdown file with format: `YYYY-MM-DD-HHmm-session.md`
3. Adds a template with session metadata and instructions
4. Prints the file path and next steps

**Workflow:**

1. When you finish a session, run the script:
   ```powershell
   .\export-session.ps1
   ```

2. The script creates a dated file like `2026-11-14-1430-session.md` in `docs/session-logs/`

3. In Claude Code:
   - Select all text in your session transcript (Ctrl+A)
   - Copy it (Ctrl+C)
   - Open the markdown file and paste the content after the "Session Content" section

4. Commit the file to git:
   ```bash
   git add docs/session-logs/
   git commit -m "Add session log: YYYY-MM-DD-HHmm"
   ```

## Automated Session Logging

In addition to manual export, every session is automatically logged by a hook in `.claude/settings.json`:

- **When:** Every time you close a Claude Code session
- **Where:** `docs/session-logs/` with automatic timestamp
- **What:** A minimal metadata file with session ID and timestamps

The hook creates a marker file; you then use `export-session.ps1` to add the full transcript.

## Session Logs Directory

All exported sessions go to `docs/session-logs/`:
- Files are **git-ignored** (see `.gitignore`)
- Format: `YYYY-MM-DD-HHmm-session.md`
- Each file contains the session transcript and metadata

Example structure:
```
docs/
  session-logs/
    2026-11-14-0900-session.md
    2026-11-14-1000-session.md
    2026-11-14-1430-session.md
```

## Notes

- Session logs are **not** committed to git (intentional - they're local reference only)
- If you want to preserve a session for the team, summarize key points in your ADRs or docs
- Use sessions logs for personal reference and session history
