__faah_err_bash() {
  local exit_code=$?
  case "${BASH_COMMAND:-}" in
    __faah_* | faah* ) return 0 ;;
  esac
  __faah_err_trapped=1
  __faah_maybe_alert "$exit_code"
  return 0
}

__faah_precmd_bash() {
  local exit_code=$?
  if [ "${__faah_err_trapped:-0}" = "1" ]; then
    __faah_err_trapped=0
    return 0
  fi
  __faah_maybe_alert "$exit_code"
}

__faah_install_bash_hooks() {
  if [ "${__faah_bash_hooks_installed:-0}" = "1" ]; then
    return
  fi
  trap '__faah_err_bash' ERR
  if declare -p PROMPT_COMMAND >/dev/null 2>&1 && declare -p PROMPT_COMMAND 2>/dev/null | grep -q 'declare \-a'; then
    local pc exists=0
    for pc in "${PROMPT_COMMAND[@]}"; do
      if [ "$pc" = "__faah_precmd_bash" ]; then
        exists=1
        break
      fi
    done
    if [ "$exists" -eq 0 ]; then
      PROMPT_COMMAND=(__faah_precmd_bash "${PROMPT_COMMAND[@]}")
    fi
  elif [ -n "${PROMPT_COMMAND:-}" ]; then
    case ";$PROMPT_COMMAND;" in
      *";__faah_precmd_bash;"*) ;;
      *) PROMPT_COMMAND="__faah_precmd_bash;$PROMPT_COMMAND" ;;
    esac
  else
    PROMPT_COMMAND="__faah_precmd_bash"
  fi
  __faah_bash_hooks_installed=1
}

__faah_precmd_zsh() {
  local exit_code=$?
  __faah_maybe_alert "$exit_code"
}

__faah_install_zsh_hooks() {
  if [ "${__faah_zsh_hooks_installed:-0}" = "1" ]; then
    return
  fi
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd __faah_precmd_zsh
  __faah_zsh_hooks_installed=1
}
