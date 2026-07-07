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

  print -- "Default branch: ${default_branch}"
  print -- "No local cleanup candidates."

  if [[ "$remote_delete" == true ]]; then
    print -- "No remote cleanup candidates."
  fi
}
