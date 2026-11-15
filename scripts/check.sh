#!/usr/bin/env sh
# Copyright 2025 Mehmet ERGULCU
# SPDX-License-Identifier: Apache-2.0
#
# Checks every folder: the compose file must be valid with the values of .env.example, and with
# --images every image tag must exist in its registry. Used by CI; run it locally the same way:
#   sh scripts/check.sh [--images]
set -eu
cd "$(dirname "$0")/.."

check_images=false
[ "${1:-}" = "--images" ] && check_images=true
failed=0

for dir in */; do
    dir=${dir%/}
    [ -f "$dir/compose.yml" ] || continue
    env_args=""
    [ -f "$dir/.env.example" ] && env_args="--env-file $dir/.env.example"
    # shellcheck disable=SC2086
    if ! docker compose --project-directory "$dir" $env_args config --quiet; then
        echo "FAIL $dir: compose file is not valid"
        failed=1
        continue
    fi
    if $check_images; then
        # shellcheck disable=SC2086
        for image in $(docker compose --project-directory "$dir" $env_args config --images); do
            if docker manifest inspect "$image" > /dev/null 2>&1; then
                echo "ok   $dir: $image"
            else
                echo "FAIL $dir: image $image not found"
                failed=1
            fi
        done
    else
        echo "ok   $dir"
    fi
done

# No two folders may publish the same host port, unless they are alternatives of each other.
ports=$(grep -hoE '^\s*- "?(127\.0\.0\.1:)?[0-9]+:[0-9]+' */compose.yml | sed -E 's/.*- "?(127\.0\.0\.1:)?([0-9]+):.*/\2/' | sort)
for port in $(echo "$ports" | uniq -d); do
    folders=$(grep -lE "^\s*- \"?(127\.0\.0\.1:)?$port:" */compose.yml | xargs -n1 dirname | tr '\n' ' ')
    case "$folders" in
        "activemq artemis "|"kafkanativewithui kafkawithoutzookeper "|"httpwithsftp sftp ") ;;
        *) echo "FAIL host port $port is used by: $folders"; failed=1 ;;
    esac
done

exit $failed
