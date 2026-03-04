#!/usr/bin/env bash

if [ -n "${ZSH_VERSION:-}" ]; then
  __faah_script_file="${(%):-%N}"
else
  __faah_script_file="${BASH_SOURCE[0]:-$0}"
fi
__faah_script_dir="$(cd "$(dirname "$__faah_script_file")" && pwd)"
__faah_default_sound="$__faah_script_dir/res/media_faah.wav"
__faah_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/faah-sh"
__faah_config_file="$__faah_config_dir/config"
__faah_state_file="${XDG_RUNTIME_DIR:-/tmp}/faah-sh-${USER:-user}.state"
__faah_err_trapped=0
__FAAH_SH_LOADED=1

__faah_require_source() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "faah: missing required file: $file" >&2
    return 1
  fi
  # shellcheck source=/dev/null
  . "$file"
}

__faah_require_source "$__faah_script_dir/lib/faah/core.sh" || return 1 2>/dev/null || exit 1
__faah_require_source "$__faah_script_dir/lib/faah/hooks.sh" || return 1 2>/dev/null || exit 1
__faah_require_source "$__faah_script_dir/lib/faah/cli.sh" || return 1 2>/dev/null || exit 1

__faah_load_config

if [ -n "${BASH_VERSION:-}" ]; then
  __faah_install_bash_hooks
elif [ -n "${ZSH_VERSION:-}" ]; then
  __faah_install_zsh_hooks
fi
