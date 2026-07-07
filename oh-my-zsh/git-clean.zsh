function __gclean_error() {
  print -u2 -- "Error: $1"
}

function __gclean_ref_exists() {
  git show-ref --verify --quiet "$1"
}

function __gclean_resolve_default_branch() {
  emulate -L zsh

  local head_target
  head_target="$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ "$head_target" == refs/remotes/origin/* ]] && __gclean_ref_exists "$head_target"; then
    print -- "${head_target#refs/remotes/origin/}"
    return 0
  fi

  if __gclean_ref_exists refs/remotes/origin/main; then
    print -- "main"
    return 0
  fi

  if __gclean_ref_exists refs/remotes/origin/master; then
    print -- "master"
    return 0
  fi

  return 1
}

function __gclean_load_protected_patterns() {
  emulate -L zsh

  typeset -g -a __gclean_protected_patterns
  __gclean_protected_patterns=(main master develop dev release staging 'master-v*' 'release/*' 'hotfix/*')

  local configured
  configured="$(git config --get cleanup.protectedBranches 2>/dev/null || true)"
  if [[ -n "$configured" ]]; then
    __gclean_protected_patterns+=(${=configured})
  fi

  local pattern
  for pattern in "${__gclean_protected_patterns[@]}"; do
    if ! zsh -fc 'emulate -L zsh; local pattern="$1"; [[ branch-name-for-validation == ${~pattern} || branch-name-for-validation != ${~pattern} ]]' zsh "$pattern" >/dev/null 2>&1; then
      __gclean_error "invalid protected branch pattern: ${pattern}"
      return 1
    fi
  done
}

function __gclean_is_protected_branch() {
  emulate -L zsh
  local branch="$1"
  shift
  local pattern

  for pattern in "$@"; do
    if [[ "$branch" == ${~pattern} ]]; then
      return 0
    fi
  done

  return 1
}

function __gclean_worktree_branches() {
  emulate -L zsh
  git worktree list --porcelain |
    while IFS= read -r line; do
      if [[ "$line" == branch\ refs/heads/* ]]; then
        print -- "${line#branch refs/heads/}"
      fi
    done
}

function __gclean_local_branch_in_sync_with_origin() {
  emulate -L zsh
  local branch="$1"
  local local_ref="refs/heads/${branch}"
  local remote_ref="refs/remotes/origin/${branch}"

  __gclean_ref_exists "$local_ref" || return 1
  __gclean_ref_exists "$remote_ref" || return 1

  local local_sha remote_sha
  local_sha="$(git rev-parse "$local_ref")" || return 1
  remote_sha="$(git rev-parse "$remote_ref")" || return 1

  [[ "$local_sha" == "$remote_sha" ]]
}

function __git-clean() {
  emulate -L zsh
  setopt pipefail

  local assume_yes=false
  local remote_delete=false
  local arg

  for arg in "$@"; do
    case "$arg" in
      --yes)
        assume_yes=true
        ;;
      --remote-delete)
        remote_delete=true
        ;;
      *)
        __gclean_error "unknown argument: ${arg}"
        return 2
        ;;
    esac
  done

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    __gclean_error "not inside a Git worktree"
    return 1
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    __gclean_error "remote 'origin' is not configured"
    return 1
  fi

  if ! git fetch --prune origin; then
    __gclean_error "git fetch --prune origin failed"
    return 1
  fi

  git worktree prune

  local default_branch
  if ! default_branch="$(__gclean_resolve_default_branch)"; then
    __gclean_error "could not resolve origin default branch"
    return 1
  fi

  if ! __gclean_load_protected_patterns; then
    return 1
  fi

  local -a protected_patterns
  protected_patterns=("${__gclean_protected_patterns[@]}")

  local current_branch
  current_branch="$(git branch --show-current)"

  local -a worktree_branches
  worktree_branches=("${(@f)$(__gclean_worktree_branches)}")

  local -a candidates skipped_reasons deleted failed
  local line branch upstream_track

  while IFS=$'\t' read -r branch upstream_track; do
    [[ -z "$branch" ]] && continue
    if [[ "$upstream_track" == "[gone]" ]]; then
      candidates+=("$branch")
    fi
  done < <(git for-each-ref --format=$'%(refname:short)\t%(upstream:track)' refs/heads)

  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    candidates+=("$branch")
  done < <(git for-each-ref --merged "refs/remotes/origin/${default_branch}" --format='%(refname:short)' refs/heads)

  local -a unique_candidates
  local seen
  for branch in "${candidates[@]}"; do
    for seen in "${unique_candidates[@]}"; do
      [[ "$seen" == "$branch" ]] && continue 2
    done
    unique_candidates+=("$branch")
  done

  candidates=()
  for branch in "${unique_candidates[@]}"; do
    if [[ "$branch" == "$current_branch" ]]; then
      skipped_reasons+=("${branch}: current branch")
      continue
    fi

    local wt_branch
    for wt_branch in "${worktree_branches[@]}"; do
      if [[ "$wt_branch" == "$branch" ]]; then
        skipped_reasons+=("${branch}: checked out in worktree")
        continue 2
      fi
    done

    if __gclean_is_protected_branch "$branch" "${protected_patterns[@]}"; then
      if ! __gclean_local_branch_in_sync_with_origin "$branch"; then
        skipped_reasons+=("${branch}: protected and not in sync with origin")
        continue
      fi
    fi

    candidates+=("$branch")
  done

  print -- "Default branch: ${default_branch}"

  if (( ${#skipped_reasons[@]} > 0 )); then
    print -- "Skipped local branches:"
    for line in "${skipped_reasons[@]}"; do
      print -- "  ${line}"
    done
  fi

  if (( ${#candidates[@]} == 0 )); then
    print -- "No local cleanup candidates."
  else
    print -- "Local cleanup candidates:"
    for branch in "${candidates[@]}"; do
      print -- "  ${branch}"
    done

    if [[ "$assume_yes" != true ]]; then
      if ! { : < /dev/tty } 2>/dev/null; then
        __gclean_error "local deletion requires a terminal confirmation"
        return 1
      fi

      local answer
      print -n -- "Delete these local branches? [y/N] " > /dev/tty
      read -r answer < /dev/tty
      if [[ "$answer" != [Yy] ]]; then
        print -- "Local deletion skipped."
        return 0
      fi
    fi

    for branch in "${candidates[@]}"; do
      if git branch -d -- "$branch"; then
        deleted+=("$branch")
      else
        failed+=("$branch")
      fi
    done
  fi

  if (( ${#deleted[@]} > 0 )); then
    print -- "Deleted local branches:"
    for branch in "${deleted[@]}"; do
      print -- "  ${branch}"
    done
  fi

  if (( ${#failed[@]} > 0 )); then
    print -- "Failed local deletions:"
    for branch in "${failed[@]}"; do
      print -- "  ${branch}"
    done
  fi

  if [[ "$remote_delete" != true ]]; then
    return 0
  fi

  local -a remote_candidates remote_deleted remote_failed
  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    [[ "$branch" == HEAD ]] && continue
    [[ "$branch" == "$default_branch" ]] && continue

    if __gclean_is_protected_branch "$branch" "${protected_patterns[@]}"; then
      continue
    fi

    remote_candidates+=("$branch")
  done < <(git for-each-ref --merged "refs/remotes/origin/${default_branch}" --format='%(refname:strip=3)' refs/remotes/origin)

  if (( ${#remote_candidates[@]} == 0 )); then
    print -- "No remote cleanup candidates."
    return 0
  fi

  print -- "Remote cleanup candidates:"
  for branch in "${remote_candidates[@]}"; do
    print -- "  ${branch}"
  done

  if ! { : < /dev/tty } 2>/dev/null; then
    __gclean_error "remote deletion requires terminal confirmation"
    return 1
  fi

  local remote_answer
  print -n -- "Type 'delete remote branches' to delete these remote branches: " > /dev/tty
  read -r remote_answer < /dev/tty
  if [[ "$remote_answer" != "delete remote branches" ]]; then
    print -- "Remote deletion skipped."
    return 0
  fi

  for branch in "${remote_candidates[@]}"; do
    if git push origin --delete -- "$branch"; then
      remote_deleted+=("$branch")
    else
      remote_failed+=("$branch")
    fi
  done

  if (( ${#remote_deleted[@]} > 0 )); then
    print -- "Deleted remote branches:"
    for branch in "${remote_deleted[@]}"; do
      print -- "  ${branch}"
    done
  fi

  if (( ${#remote_failed[@]} > 0 )); then
    print -- "Failed remote deletions:"
    for branch in "${remote_failed[@]}"; do
      print -- "  ${branch}"
    done
  fi
}
