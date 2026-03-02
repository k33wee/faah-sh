__faah_defaults() {
  : "${FAAH_ENABLED:=1}"
  : "${FAAH_COOLDOWN_SECONDS:=10}"
  : "${FAAH_QUIET_HOURS:=}"
  : "${FAAH_SNOOZE_UNTIL:=0}"
  if [ -f "$__faah_default_sound" ]; then
    : "${FAAH_SOUND_FILE:=$__faah_default_sound}"
  else
    : "${FAAH_SOUND_FILE:=}"
  fi
}

__faah_escape_squotes() {
  printf "%s" "$1" | sed "s/'/'\"'\"'/g"
}

__faah_resolve_sound_file() {
  local candidate="$1"
  [ -n "$candidate" ] || return 1
  if [ -f "$candidate" ]; then
    printf "%s" "$candidate"
    return 0
  fi
  if [ "${candidate#/}" = "$candidate" ]; then
    local rel="${candidate#./}"
    if [ -f "$__faah_script_dir/$rel" ]; then
      printf "%s" "$__faah_script_dir/$rel"
      return 0
    fi
  fi
  return 1
}

__faah_save_config() {
  mkdir -p "$__faah_config_dir"
  cat >"$__faah_config_file" <<EOF
FAAH_ENABLED='$(__faah_escape_squotes "$FAAH_ENABLED")'
FAAH_COOLDOWN_SECONDS='$(__faah_escape_squotes "$FAAH_COOLDOWN_SECONDS")'
FAAH_QUIET_HOURS='$(__faah_escape_squotes "$FAAH_QUIET_HOURS")'
FAAH_SNOOZE_UNTIL='$(__faah_escape_squotes "$FAAH_SNOOZE_UNTIL")'
FAAH_SOUND_FILE='$(__faah_escape_squotes "$FAAH_SOUND_FILE")'
EOF
}

__faah_load_config() {
  local resolved_sound
  __faah_defaults
  if [ -f "$__faah_config_file" ]; then
    # shellcheck source=/dev/null
    . "$__faah_config_file"
  fi
  __faah_defaults
  if resolved_sound="$(__faah_resolve_sound_file "$FAAH_SOUND_FILE")"; then
    FAAH_SOUND_FILE="$resolved_sound"
  elif [ -f "$__faah_default_sound" ]; then
    FAAH_SOUND_FILE="$__faah_default_sound"
  fi
}

__faah_now() {
  date +%s
}

__faah_minutes_now() {
  local hh mm
  hh="$(date +%H)"
  mm="$(date +%M)"
  printf "%s" $((10#$hh * 60 + 10#$mm))
}

__faah_hhmm_to_minutes() {
  local value="$1"
  local hh="${value%:*}"
  local mm="${value#*:}"
  printf "%s" $((10#$hh * 60 + 10#$mm))
}

__faah_in_quiet_hours() {
  [ -n "$FAAH_QUIET_HOURS" ] || return 1
  local start="${FAAH_QUIET_HOURS%-*}"
  local end="${FAAH_QUIET_HOURS#*-}"
  [[ "$start" =~ ^[0-9]{2}:[0-9]{2}$ ]] || return 1
  [[ "$end" =~ ^[0-9]{2}:[0-9]{2}$ ]] || return 1

  local now start_m end_m
  now="$(__faah_minutes_now)"
  start_m="$(__faah_hhmm_to_minutes "$start")"
  end_m="$(__faah_hhmm_to_minutes "$end")"

  if [ "$start_m" -lt "$end_m" ]; then
    [ "$now" -ge "$start_m" ] && [ "$now" -lt "$end_m" ]
    return
  fi

  if [ "$start_m" -gt "$end_m" ]; then
    [ "$now" -ge "$start_m" ] || [ "$now" -lt "$end_m" ]
    return
  fi

  return 1
}

__faah_read_last_alert() {
  if [ -f "$__faah_state_file" ]; then
    head -n 1 "$__faah_state_file"
    return
  fi
  printf "0"
}

__faah_write_last_alert() {
  mkdir -p "$(dirname "$__faah_state_file")"
  printf "%s\n" "$1" >"$__faah_state_file"
}

__faah_play_sound_file() {
  local file="$1"
  if command -v paplay >/dev/null 2>&1; then
    paplay "$file" >/dev/null 2>&1 &
    return 0
  fi
  if command -v aplay >/dev/null 2>&1; then
    aplay -q "$file" >/dev/null 2>&1 &
    return 0
  fi
  if command -v afplay >/dev/null 2>&1; then
    afplay "$file" >/dev/null 2>&1 &
    return 0
  fi
  if command -v play >/dev/null 2>&1; then
    play -q "$file" >/dev/null 2>&1 &
    return 0
  fi
  if command -v ffplay >/dev/null 2>&1; then
    ffplay -nodisp -autoexit -loglevel quiet "$file" >/dev/null 2>&1 &
    return 0
  fi
  return 1
}

__faah_play() {
  local resolved_sound
  if resolved_sound="$(__faah_resolve_sound_file "$FAAH_SOUND_FILE")"; then
    __faah_play_sound_file "$resolved_sound" && return 0
  elif [ -f "$__faah_default_sound" ]; then
    __faah_play_sound_file "$__faah_default_sound" && return 0
  fi
  printf '\a'
}

__faah_should_alert() {
  local exit_code="$1"
  [ "$FAAH_ENABLED" = "1" ] || return 1
  [ "$exit_code" -ne 0 ] || return 1

  local now last cooldown
  now="$(__faah_now)"

  if [ "$FAAH_SNOOZE_UNTIL" -gt "$now" ]; then
    return 1
  fi

  __faah_in_quiet_hours && return 1

  last="$(__faah_read_last_alert)"
  cooldown="${FAAH_COOLDOWN_SECONDS:-0}"

  if [ "$cooldown" -gt 0 ] && [ $((now - last)) -lt "$cooldown" ]; then
    return 1
  fi

  return 0
}

__faah_maybe_alert() {
  local exit_code="$1"
  __faah_should_alert "$exit_code" || return 0
  __faah_play
  __faah_write_last_alert "$(__faah_now)"
}
