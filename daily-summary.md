---
name: daily-summary
description: Generate a daily development summary from local git repositories. Scans for commits, analyzes changes, extracts architectural decisions, and creates Anki cards. Use when you want a summary of today's coding work.
---

You are helping the user generate a daily development summary from their local git repositories.

## Step 1 — Load config

Read the config file at `~/.claude/daily-summary-config.json`.

It contains:
- `scan_paths`: list of root directories to scan recursively for git repos
- `output_dir`: where to save the summary markdown file
- `git_author`: git author name or email to filter commits by

If the file does not exist, create it from the example config at the skill's repo (`daily-summary-config.example.json`) and then ask the user to provide values for each field. Offer to update the config file for them.

Validate every field:
- `scan_paths`: each entry must look like a plausible directory path (starts with `~/`, `/`, or `.`). Expand `~` and verify the directories exist using `ls`. Drop any that don't exist and warn the user. If none are valid, ask the user which directories to scan.
- `output_dir`: must look like a plausible directory path (starts with `~/`, `/`, or `.`). If it doesn't (e.g. contains comments, random text, or is clearly not a path), ask the user for a valid directory. If the directory doesn't exist yet, that's fine — it will be created later.
- `git_author`: must not be empty or still have the placeholder value "Your Name or email". If invalid, try to auto-detect by running `git config user.name` and `git config user.email`, propose the detected values, and ask the user to confirm.

If any field is missing, empty, or invalid, stop and ask the user to provide correct values. Offer to update the config file for them. Do NOT proceed to Step 2 until all fields are valid.

If the user asks to change a setting (e.g. "use ~/work instead" or "change my name to X"), update the config file accordingly before proceeding.

## Step 2 — Discover repositories

For each path in `scan_paths`, recursively find all directories containing a `.git` folder.
Use: `find <path> -name ".git" -type d -not -path "*/.git/*" 2>/dev/null`
The parent of each `.git` directory is a repository root.

Expand `~` to the actual home directory before running commands.

## Step 3 — Collect today's changes

For each discovered repository, run:
```
git -C <repo_path> log --since="24 hours ago" --author="<git_author>" --format="%H|%s|%ai" --stat
```

Skip repos with no output (no commits today by this author).

For repos with commits, also run:
```
git -C <repo_path> diff --stat HEAD~<n> HEAD
```
where `<n>` is the number of commits from the log, to get a fuller picture of what changed.

For each commit with meaningful changes (not just formatting, dependency bumps, or whitespace), also fetch the diff:
```
git -C <repo_path> show <commit_hash> --stat --unified=3
```

## Step 4 — Analyze and summarize

For each repository that had changes, produce a structured analysis:

**Changes section**: Summarize what actually changed in plain language. Focus on behaviour, not file names.

**Architectural Decisions section**: Extract any decision that reflects a design choice — what pattern was chosen, why, and what trade-offs it brings. If you cannot infer a reason from the diff or commit message, note it as "reason not captured in commit".

**Anki Cards section**: Write 2–4 cards per repo. Cards must test *understanding of reasoning*, not trivia. Format:
```
Q: <question targeting why or how a decision was made>
A: <concise answer including the reasoning>
```

Skip trivial changes entirely (formatting commits, version bumps, lock file changes with no logic change).

## Step 5 — Write the output file

Today's date: use the current system date.

Output file path: `<output_dir>/YYYY-MM-DD.md`

Expand `~` to the actual home directory. Create the output directory if it does not exist.

Write the file using this structure:

```markdown
# Daily Dev Summary — YYYY-MM-DD

## Repository: <repo-name>
**Path:** <full path>
**Commits today:** <n>

### Changes
- <plain language summary of what changed>

### Architectural Decisions
- **Decision:** <what was decided>
  **Why:** <reasoning extracted from diff/commit>
  **Trade-offs:** <any downsides or alternatives considered>

### Anki Cards
Q: <question>
A: <answer>

---

## Repository: <next-repo>
...

---

## Meta
- Total repos scanned: <n>
- Repos with changes: <n>
- Total commits: <n>
- Author filter: <git_author>
- Generated: YYYY-MM-DD HH:MM
```

After writing the file, tell the user:
- Where the file was saved
- How many repos had changes
- How many Anki cards were generated
- Offer to open the file or adjust anything
