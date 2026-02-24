# antigravity-destructive-command-guard-dcg

A [dcg](https://github.com/Dicklesworthstone/destructive_command_guard) (Destructive Command Guard) integration for [Google Antigravity IDE](https://antigravity.google).

## Why

AI coding agents in Antigravity IDE can accidentally run destructive commands that destroy your work:

| Incident | Command | Damage |
|----------|---------|--------|
| Drive wipe | `rmdir /s /q d:\` | Entire D: drive — years of photos, code, media |
| Home folder | `rm -rf ~/Documents ~/Downloads` | User's home directory contents |
| Git history | `git reset --hard HEAD~1` | All uncommitted changes |
| Database | `DROP TABLE users` | Production data |

dcg catches these commands **before they execute** and blocks them with clear explanations.

## How It Works

Antigravity IDE does not have a programmatic hook API (unlike Claude Code or Gemini CLI). This integration uses Antigravity's **Skills** system — a `SKILL.md` file that instructs the agent to check every command through `dcg test` before running it.

This is a "soft" guard — the agent follows the skill's instructions but is not mechanically forced to comply. For most use cases, the agent reliably follows well-written skills.

```
User asks agent to clean cache
     │
     ▼
Agent generates: rm -rf /project/.cache
     │
     ▼
Skill triggers: dcg test "rm -rf /project/.cache"
     │
     ├─ Exit 0 (safe) → Agent executes command
     │
     └─ Exit 1 (blocked) → Agent reports block to user
                            with reason and safer alternative
```

## Prerequisites

- [dcg](https://github.com/Dicklesworthstone/destructive_command_guard) installed (`dcg` on your PATH)
- [Google Antigravity IDE](https://antigravity.google/download) installed

## Install

### Option 1: Installer script

```bash
git clone https://github.com/matznerd/antigravity-destructive-command-guard-dcg.git
cd antigravity-destructive-command-guard-dcg
./install.sh
```

### Option 2: Manual

```bash
mkdir -p ~/.gemini/antigravity/skills/dcg-guard
cp SKILL.md ~/.gemini/antigravity/skills/dcg-guard/SKILL.md
```

### Option 3: One-liner

```bash
mkdir -p ~/.gemini/antigravity/skills/dcg-guard && \
curl -fsSL https://raw.githubusercontent.com/matznerd/antigravity-destructive-command-guard-dcg/main/SKILL.md \
  -o ~/.gemini/antigravity/skills/dcg-guard/SKILL.md
```

## Verify (safe — dcg never executes commands)

```bash
# These only do string matching, they never run the actual commands:
dcg test "git reset --hard"    # → BLOCKED
dcg test "rm -rf /"            # → BLOCKED
dcg test "git status"          # → allowed
dcg test "ls -la"              # → allowed
```

## Configuration

Optionally configure dcg's behavior for Antigravity in `~/.config/dcg/config.toml`:

```toml
[agents.antigravity]
trust_level = "medium"

# Enable additional protection packs
[packs]
enabled = [
    "database.postgresql",
    "kubernetes.kubectl",
    "cloud.aws",
    "containers.docker",
]
```

## Scope: Global vs Per-Project

- **Global** (recommended): Install to `~/.gemini/antigravity/skills/dcg-guard/SKILL.md` — protects all projects
- **Per-project**: Install to `<project>/.agent/skills/dcg-guard/SKILL.md` — protects only that project

## Limitations

- **Soft enforcement**: Unlike Claude Code's `PreToolUse` hook (which mechanically blocks commands), this skill relies on the Antigravity agent following instructions. In rare cases, the agent may skip the check.
- **Turbo mode**: When Antigravity is in Turbo mode, commands may auto-execute before the skill triggers. Consider using Auto or Off mode for maximum safety.
- **No hook API**: Google has not added a programmatic pre-execution hook to Antigravity. If/when they do, dcg can integrate more tightly.

## License

MIT — same as [dcg](https://github.com/Dicklesworthstone/destructive_command_guard).
