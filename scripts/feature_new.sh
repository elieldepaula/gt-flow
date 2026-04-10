#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_feature_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature new"
    
    if branch_exists "${FET_BRANCH}${FET_PREFIX}$name"; then
        echo "Error: Branch '${FET_BRANCH}${FET_PREFIX}$name' already exists."
        exit 1
    fi
    
    local source=$(get_source_branch "fet")
    git checkout -b "${FET_BRANCH}${FET_PREFIX}$name" "$source"
    echo "✓ Branch '${FET_BRANCH}${FET_PREFIX}$name' created from '$source'"
}

