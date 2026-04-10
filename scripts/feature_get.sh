#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_feature_get() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature get"
    
    local branch="${FET_BRANCH}${FET_PREFIX}$name"
    
    if ! git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
        echo "Error: Branch '$branch' does not exist on remote."
        exit 1
    fi
    
    if branch_exists "$branch"; then
        git checkout "$branch"
        git pull origin "$branch"
    else
        git checkout -b "$branch" "origin/$branch"
        git pull origin "$branch"
    fi
    
    echo "✓ Feature '$branch' pulled from origin"
}
