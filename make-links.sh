#!/bin/sh
set -eu

link_file() {
    local src="$1" dst="$2"
    if [ -f "$dst" ]; then
        echo "$dst already exists"
    else
        ln -s "$src" "$dst"
    fi
}

THISDIR="$(cd "$(dirname "$0")" && pwd)"

link_file "$THISDIR/.gitconfig" "$HOME/.gitconfig"
link_file "$THISDIR/.tmux.conf" "$HOME/.tmux.conf"
link_file "$THISDIR/.inputrc"   "$HOME/.inputrc"
