# Extend NetBird's generated completion with peer names for SSH destinations.
# Keep the cache in this shell, including failed refreshes, to avoid repeated
# daemon requests when Tab is pressed several times.
typeset -ga _netbird_peer_hosts
typeset -gi _netbird_peer_checked=${_netbird_peer_checked:--30}

_netbird_ssh_peer_hosts() {
  setopt localoptions pipefail
  local peers

  if (( SECONDS - _netbird_peer_checked >= 30 )); then
    _netbird_peer_checked=$SECONDS
    if (( $+commands[timeout] && $+commands[jq] )) &&
      peers=$(command timeout 2s netbird status --json 2>/dev/null |
        command jq -r '.peers.details | if type != "array" then
          error("Missing peer list") else
          [.[].fqdn | select(type == "string" and length > 0)] | unique | .[]
          end' 2>/dev/null); then
      _netbird_peer_hosts=()
      [[ -n $peers ]] && _netbird_peer_hosts=("${(@f)peers}")
    fi
  fi

  # Complete only the hostname part while preserving a supplied user@ prefix.
  compset -P '*@'
  if (( $#_netbird_peer_hosts )); then
    _wanted hosts expl 'NetBird peer' compadd -a _netbird_peer_hosts
  else
    _message 'No NetBird peers available (check netbird status)'
  fi
}

_netbird_with_peers() {
  local -a words=("${words[@]}")
  local expl word
  local -i index=3 expect_value=0 options_done=0
  words[1]=netbird

  if [[ ${words[2]} == ssh ]] && (( CURRENT >= 3 )); then
    # Locate the destination without mistaking SSH option values or a remote
    # command argument for a host. Delegate everything else to native completion.
    while (( index < CURRENT )); do
      word=${words[index]}
      if (( expect_value )); then
        expect_value=0
      elif (( options_done )); then
        _netbird
        return
      else
        case $word in
          --) options_done=1 ;;
          -p|--port|-u|--user|--login|-o|--known-hosts|-i|--identity|-L|-R|--L|--R)
            expect_value=1 ;;
          --port=*|--user=*|--login=*|--known-hosts=*|--identity=*|--L=*|--R=*) ;;
          -t|--tty|--no-browser|--no-cache|--strict-host-key-checking|--strict-host-key-checking=*) ;;
          *) _netbird; return ;;
        esac
      fi
      (( index++ ))
    done

    if (( ! expect_value )) && { (( options_done )) || [[ ${words[CURRENT]} != -* ]]; }; then
      _netbird_ssh_peer_hosts
      return
    fi
  fi

  _netbird
}

compdef _netbird_with_peers netbird nb
