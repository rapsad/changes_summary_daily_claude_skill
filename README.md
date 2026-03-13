# Daily Dev Summary — Claude Code Skill

A Claude Code skill that scans your local git repositories at the end of each day, summarizes what changed, extracts architectural decisions, and generates Anki flashcards to help you retain what you built.

## What it produces

For each repository with commits today, the skill generates:

- **Changes** — plain language summary of what actually changed
- **Architectural Decisions** — the *why* behind design choices, extracted from diffs and commit messages
- **Anki Cards** — 2–4 ready-to-import flashcards per repo, testing reasoning not trivia

Output is saved as a dated Markdown file: `~/dev-summaries/2026-03-13.md`

## Requirements

- [Claude Code](https://claude.ai/code) installed
- Git

## Installation

### Option A — One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/rapsad/changes_summary_daily_claude_skill/main/install.sh | bash
```

### Option B — Clone and run locally

```bash
git clone https://github.com/rapsad/changes_summary_daily_claude_skill.git
cd changes_summary_daily_claude_skill
bash install.sh
```

### Option C — Manual

1. Copy `daily-summary.md` to `~/.claude/skills/daily-summary.md`
2. Copy `daily-summary-config.example.json` to `~/.claude/daily-summary-config.json`
3. Edit the config with your details (see below)

## Configuration

Config lives at `~/.claude/daily-summary-config.json`:

```json
{
  "scan_paths": [
    "~/projects",
    "~/work"
  ],
  "output_dir": "~/dev-summaries",
  "git_author": "Your Name or email"
}
```

| Field | Description |
|---|---|
| `scan_paths` | List of root directories. All nested git repos inside will be scanned. |
| `output_dir` | Where daily summary files are saved. Created automatically if missing. |
| `git_author` | Your git author name or email. Only commits from this author are included. |

You can add multiple paths to `scan_paths` and they will all be scanned recursively.

You can also ask Claude to update the config mid-conversation:
> "Add ~/work to my scan paths"
> "Change my author to jane@example.com"

## Usage

Open Claude Code in any directory and run:

```
/daily-summary
```

That's it. Claude will scan your repos, analyze the changes, and write the summary file.

## Anki Integration

The generated Markdown file contains a `### Anki Cards` section per repo. To import into Anki:

1. Copy the Q/A pairs from the summary file
2. Use [AnkiConnect](https://ankiweb.net/shared/info/2055492159) or the Anki importer to add them to your deck
3. Choose a Basic note type with Front/Back fields

A future version may automate this step.

## Example Output

```markdown
# Daily Dev Summary — 2026-03-13

## Repository: my-app
**Path:** ~/projects/my-app
**Commits today:** 2

### Changes
- Added JWT refresh token rotation in `auth/tokens.ts`
- Extracted read/write responsibilities from `UserService`

### Architectural Decisions
- **Decision:** Refresh token rotation over long-lived tokens
  **Why:** Reduces exposure window if a token is stolen
  **Trade-offs:** More round-trips to the auth server

### Anki Cards
Q: Why was refresh token rotation chosen over long-lived tokens in my-app?
A: Reduces exposure window if stolen. Trade-off: more round-trips to auth server.

Q: What responsibility was extracted from UserService?
A: Write operations — separated from reads to follow single responsibility principle.
```

## License

MIT
