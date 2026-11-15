#!/usr/bin/env sh
# Copyright 2025 Mehmet ERGULCU
# SPDX-License-Identifier: Apache-2.0
#
# Lists the folders, starts the chosen one with "docker compose up" and stops it with Ctrl+C.
# A missing .env is copied from .env.example first.
set -eu
cd "$(dirname "$0")"

i=0
for dir in */; do
    dir=${dir%/}
    [ -f "$dir/compose.yml" ] || continue
    i=$((i + 1))
    echo "$i: $dir"
    eval "folder_$i=\$dir"
done

printf 'Number of the folder to start: '
read -r selection
case $selection in
    '' | *[!0-9]*) echo "Invalid selection." >&2; exit 1 ;;
esac
eval "selected=\${folder_$selection:-}"
[ -n "$selected" ] || { echo "Invalid selection." >&2; exit 1; }

cd "$selected"
if [ -f .env.example ] && [ ! -f .env ]; then
    cp .env.example .env
    echo "Created $selected/.env from .env.example; change the passwords there if needed."
fi
exec docker compose up
