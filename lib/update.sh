#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

GITHUB_REPO="elieldepaula/gt-flow"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

get_latest_version() {
    local latest=$(curl -s "$GITHUB_API" | grep '"tag_name"' | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
    echo "$latest"
}

compare_versions() {
    local current="$1"
    local latest="$2"

    if [ "$(printf '%s\n' "$latest" "$current" | sort -V | head -n1)" != "$latest" ]; then
        return 0
    fi
    return 1
}

cmd_update_check() {
    local current="${CURRENT_VERSION}"
    local latest=$(get_latest_version)

    if [ -z "$latest" ]; then
        echo "Unable to check for updates."
        return
    fi

    if compare_versions "$current" "$latest"; then
        echo "Update available: $latest (current: $current)"
        echo "Visit: https://github.com/$GITHUB_REPO/releases"
    else
        echo "GT-Flow is up to date (version $current)."
    fi
}
