---
name: dcg-guard
description: >
  Before executing ANY terminal or shell command, check it against
  the Destructive Command Guard (dcg) to prevent accidental data loss
  from commands like rm -rf, git reset --hard, rmdir /s /q, DROP TABLE,
  docker system prune, kubectl delete namespace, and more.
---

## Goal

Prevent destructive commands from executing by checking every shell command
through dcg before running it. This protects against accidental file deletion,
git history destruction, database drops, and other irreversible operations.

## Background

AI coding agents occasionally run catastrophic commands that destroy hours of
work in seconds. Documented incidents include:
- Entire drive wiped via `rmdir /s /q d:\` (Antigravity Turbo mode)
- Home folder deleted via `rm -rf ~/Documents ~/Downloads`
- Production database dropped via `DROP TABLE`
- Git history destroyed via `git reset --hard`

dcg catches these commands BEFORE they execute and blocks them with clear
explanations and safer alternatives.

## Instructions

1. Before executing ANY shell or terminal command, first run this check:
   ```
   dcg test --format json "<the-command-here>"
   ```
2. Read the exit code:
   - **Exit 0** = command is safe. Proceed to execute it normally.
   - **Exit 1** = command is BLOCKED. Do NOT execute it.
3. If blocked (exit 1), parse the JSON output. Key fields:
   ```json
   {
     "decision": "deny",
     "reason": "git reset --hard destroys uncommitted changes. Use 'git stash' first.",
     "severity": "critical",
     "explanation": "Detailed explanation of what the command does and safer alternatives"
   }
   ```
4. Report the block to the user with:
   - The reason from dcg's output
   - The severity level
   - The explanation, which includes safer alternatives
5. NEVER skip this check, even for commands that seem safe.
6. If dcg is not installed or the `dcg` command fails to run, warn the user
   and ask for explicit confirmation before proceeding with any command.

## Examples

Safe command (dcg exits 0):
```
$ dcg test --format json "git status"
# exit code: 0 → proceed
```

Blocked command (dcg exits 1):
```
$ dcg test --format json "git reset --hard"
# exit code: 1 → DO NOT EXECUTE
# JSON output includes:
#   "reason": "git reset --hard destroys uncommitted changes. Use 'git stash' first."
#   "severity": "critical"
#   "explanation": "... safer alternatives ..."
```

## Constraints

- Never bypass or skip the dcg check for any shell command
- Never execute a command that dcg has blocked
- Always show the user dcg's reason when a command is blocked
- If dcg's explanation suggests safer alternatives, present them to the user
