# Git Clean Alias Design

## Context

This repository keeps personal zsh configuration in `oh-my-zsh/.zshrc`.
Existing Git helpers in that file use shell functions with short aliases. The
cleanup helper should follow that pattern: a zsh function for logic and a short
alias for day-to-day use.

The goal is to clean stale branch state in local repositories without making
remote destructive behavior easy to trigger accidentally.

## Command Surface

Add one zsh function exposed as `gclean`.

```sh
alias gclean=__git-clean
```

Supported invocations:

```sh
gclean
gclean --yes
gclean --remote-delete
gclean --remote-delete --yes
```

`gclean` performs local cleanup with confirmation. `--yes` skips only the
local branch deletion prompt. `--remote-delete` enables remote-server branch
deletion, but remote deletion always requires an explicit typed confirmation,
even when `--yes` is present.

## Scope

Version 1 is `origin`-only.

The function requires:

- the current directory to be inside a Git worktree
- an `origin` remote to exist
- `git fetch --prune origin` to complete successfully

If any of these checks fail, the function stops before branch deletion. The
function also runs `git worktree prune` after the successful fetch so stale
worktree metadata is cleaned before branch candidates are computed.

Repositories without `origin`, multi-remote cleanup, and local-only cleanup are
out of scope for version 1.

## Default Branch Resolution

The function resolves the default branch from verified remote-tracking refs. It
does not use local `main` or `master` branches for merge checks.

Resolution order:

1. Use `refs/remotes/origin/HEAD` if it resolves to an existing
   `refs/remotes/origin/<branch>` ref.
2. Otherwise use `refs/remotes/origin/main` if it exists.
3. Otherwise use `refs/remotes/origin/master` if it exists.
4. Otherwise stop with a clear error.

The resolved default branch has two forms:

- short name: `main`, `master`, `regolith3.2`, etc.
- remote ref: `refs/remotes/origin/<name>`

The remote ref is used for merged-branch checks. The short name is used for
protection and display.

## Local Cleanup

Local stale branch candidates come from two sources:

- local branches whose configured upstream is gone
- local branches already merged into the resolved `origin/<default>` branch

Detection must use structured Git output, not porcelain parsing. Use
`git for-each-ref` for local branch names, upstream refs, and upstream tracking
state.

The function excludes branches that are currently checked out in any worktree.
These branches should be reported as skipped when they would otherwise be
cleanup candidates.

Local deletion uses:

```sh
git branch -d -- <branch>
```

The function does not force-delete local branches in version 1. A gone-upstream
branch may still be refused by Git if it is not merged; that refusal is reported
as a failed deletion, not treated as a successful cleanup.

## Remote Cleanup

Remote-server deletion runs only with `--remote-delete`.

Remote candidates are remote-tracking branches under `refs/remotes/origin/*`
that are merged into the resolved default remote ref. Candidate construction
must strip exactly the `refs/remotes/origin/` prefix and operate on normalized
short names such as `feature/foo` or `release/2026-07`.

Remote deletion excludes:

- `origin/HEAD`
- the resolved default branch
- all protected branch patterns

Before deleting any remote branch, the function prints the exact branches and
requires the user to type:

```text
delete remote branches
```

Only then does it run:

```sh
git push origin --delete -- <branch>
```

Each branch name is passed as a quoted array element. Remote deletion fails
closed when no terminal is available for confirmation.

## Protected Branch Policy

Git cannot read GitHub, GitLab, or Bitbucket protected-branch metadata through a
portable Git-native command. Protection is therefore name-pattern based.

Built-in protected patterns:

```text
main master develop dev release staging master-v* release/* hotfix/*
```

Additional patterns may be configured through Git config:

```sh
git config --global cleanup.protectedBranches 'production/* qa/*'
```

Configured patterns extend the built-in defaults; they do not replace them.
Patterns are whitespace-separated and matched against normalized short branch
names. Local branch `release/foo` and remote branch `origin/release/foo` both
match the pattern `release/*` after normalization.

The resolved default branch is always protected from remote-server deletion,
even if it does not match any configured pattern.

For local deletion, protected-pattern branches may still be deleted when they
are exactly recoverable from `origin`. A protected local branch is eligible for
local deletion only when all of the following are true:

- it is not the current branch
- it is not checked out in another worktree
- `refs/remotes/origin/<branch>` exists
- `refs/heads/<branch>` and `refs/remotes/origin/<branch>` point to the exact
  same commit
- it is otherwise a cleanup candidate

This allows local branches such as `master-v1` to be removed when they are in
sync with `origin/master-v1`, while still preventing accidental remote deletion
of `origin/master-v1`.

## Confirmation Behavior

Prompts read from `/dev/tty`, not standard input.

Local deletion:

- `gclean` prints local candidates and prompts before deleting
- `gclean --yes` skips the local prompt
- if a prompt is required and no terminal is available, local deletion stops

Remote deletion:

- always prompts by requiring the typed phrase `delete remote branches`
- ignores `--yes`
- stops when no terminal is available

## Zsh Implementation Constraints

The function should start with:

```sh
emulate -L zsh
```

Pattern matching should be deliberate and fail closed. Invalid configured
patterns should stop cleanup with a clear error instead of silently leaving
branches unprotected.

Branch lists should be stored in arrays, and branch names should be quoted when
passed to Git commands.

## Output And Failure Handling

The function should show:

- the resolved default branch
- local deletion candidates
- skipped branches with reasons, such as protected, current branch, checked out
  in another worktree, or protected and not in sync with `origin`
- successfully deleted local branches
- local branches Git refused to delete
- remote deletion candidates when `--remote-delete` is used
- successfully deleted remote branches
- remote branches Git failed to delete

If `git fetch --prune origin` fails, no branch deletion should run. If an
individual branch deletion fails, the function should continue to the next
candidate and summarize failures at the end.

## Non-Goals

Version 1 does not include:

- forced local branch deletion
- deletion across remotes other than `origin`
- automatic discovery of hosting-platform protected branches through `gh`,
  `glab`, or provider APIs
- `git gc` or aggressive repository maintenance
- fixing unrelated zsh helpers near the Git alias section

## Verification Plan

Implementation should be verified with temporary Git repositories that cover:

- no Git repository
- repository without `origin`
- valid `origin/HEAD`
- fallback to `origin/main` or `origin/master`
- nonstandard default branch such as `origin/regolith3.2`
- local gone-upstream branch
- local merged branch
- protected local branch in sync with `origin`
- protected local branch not in sync with `origin`
- branch checked out in another worktree
- remote deletion candidate
- protected remote branch excluded from remote deletion
- `--yes` skipping only local confirmation
- remote deletion requiring typed confirmation
