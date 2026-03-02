#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_line="source \"$script_dir/faah.sh\""
mode="${1:-install}"

# shellcheck source=/dev/null
. "$script_dir/lib/install/rc_lines.sh"

case "$mode" in
  install)
    add_source_line "$HOME/.bashrc"
    add_source_line "$HOME/.zshrc"
    echo "Done. Open a new shell or run: $source_line"
    ;;
  --uninstall|uninstall)
    remove_source_line "$HOME/.bashrc"
    remove_source_line "$HOME/.zshrc"
    echo "Done. Open a new shell."
    ;;
  *)
    echo "usage: ./install.sh [install|uninstall|--uninstall]"
    exit 1
    ;;
esac
