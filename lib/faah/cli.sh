faah() {
  local cmd="${1:-status}"
  case "$cmd" in
  on)
    FAAH_ENABLED=1
    __faah_save_config
    echo "faah: enabled"
    ;;
  off)
    FAAH_ENABLED=0
    __faah_save_config
    echo "faah: disabled"
    ;;
  toggle)
    if [ "$FAAH_ENABLED" = "1" ]; then
      FAAH_ENABLED=0
      echo "faah: disabled"
    else
      FAAH_ENABLED=1
      echo "faah: enabled"
    fi
    __faah_save_config
    ;;
  cooldown)
    if ! [[ "${2:-}" =~ ^[0-9]+$ ]]; then
      echo "usage: faah cooldown <seconds>"
      return 1
    fi
    FAAH_COOLDOWN_SECONDS="$2"
    __faah_save_config
    echo "faah: cooldown=${FAAH_COOLDOWN_SECONDS}s"
    ;;
  quiet)
    if [ "${2:-}" = "off" ]; then
      FAAH_QUIET_HOURS=""
    elif [[ "${2:-}" =~ ^[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}$ ]]; then
      FAAH_QUIET_HOURS="$2"
    else
      echo "usage: faah quiet <HH:MM-HH:MM|off>"
      return 1
    fi
    __faah_save_config
    echo "faah: quiet-hours=${FAAH_QUIET_HOURS:-off}"
    ;;
  snooze)
    if ! [[ "${2:-}" =~ ^[0-9]+$ ]]; then
      echo "usage: faah snooze <minutes>"
      return 1
    fi
    FAAH_SNOOZE_UNTIL=$(( $(__faah_now) + $2 * 60 ))
    __faah_save_config
    echo "faah: snoozed for ${2}m"
    ;;
  clear-snooze)
    FAAH_SNOOZE_UNTIL=0
    __faah_save_config
    echo "faah: snooze cleared"
    ;;
  sound)
    local sound_path
    if [ -z "${2:-}" ]; then
      echo "usage: faah sound <file>"
      return 1
    fi
    if [ ! -f "$2" ]; then
      echo "faah: file not found: $2"
      return 1
    fi
    sound_path="$2"
    if [ "${sound_path#/}" = "$sound_path" ]; then
      FAAH_SOUND_FILE="$(cd "$(dirname "$sound_path")" && pwd)/$(basename "$sound_path")"
    else
      FAAH_SOUND_FILE="$sound_path"
    fi
    __faah_save_config
    echo "faah: sound=$FAAH_SOUND_FILE"
    ;;
  test)
    __faah_play
    ;;
  status)
    local now remaining
    now="$(__faah_now)"
    if [ "$FAAH_SNOOZE_UNTIL" -gt "$now" ]; then
      remaining=$((FAAH_SNOOZE_UNTIL - now))
    else
      remaining=0
    fi
    cat <<EOF
enabled: $FAAH_ENABLED
cooldown_seconds: $FAAH_COOLDOWN_SECONDS
quiet_hours: ${FAAH_QUIET_HOURS:-off}
snooze_remaining_seconds: $remaining
sound_file: ${FAAH_SOUND_FILE:-bell}
EOF
    ;;
  help | --help | -h)
    cat <<'EOF'
faah commands:
  faah on|off|toggle
  faah status
  faah test
  faah cooldown <seconds>
  faah quiet <HH:MM-HH:MM|off>
  faah snooze <minutes>
  faah clear-snooze
  faah sound <file>
EOF
    ;;
  *)
    echo "faah: unknown command '$cmd' (try: faah help)"
    return 1
    ;;
  esac
}
