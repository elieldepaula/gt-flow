#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' already exists."
        exit 1
    fi
    
    local source=$(get_source_branch "rel")
    git checkout -b "${REL_BRANCH}${REL_PREFIX}$name" "$source"
    echo "✓ Branch '${REL_BRANCH}${REL_PREFIX}$name' created from '$source'"
}
