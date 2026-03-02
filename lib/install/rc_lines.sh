add_source_line() {
  local rc_file="$1"
  [ -f "$rc_file" ] || touch "$rc_file"
  if ! grep -Fqx "$source_line" "$rc_file"; then
    printf "\n%s\n" "$source_line" >>"$rc_file"
    echo "updated: $rc_file"
  else
    echo "exists:  $rc_file"
  fi
}

remove_source_line() {
  local rc_file="$1"
  local tmp_file
  [ -f "$rc_file" ] || return 0
  if grep -Fqx "$source_line" "$rc_file"; then
    tmp_file="$(mktemp)"
    grep -Fvx "$source_line" "$rc_file" >"$tmp_file" || true
    mv "$tmp_file" "$rc_file"
    echo "updated: $rc_file"
  else
    echo "exists:  $rc_file (no faah entry)"
  fi
}
