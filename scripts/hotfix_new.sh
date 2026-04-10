#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_hotfix_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "hotfix new"
    
    if branch_exists "${HOT_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${HOT_BRANCH}${REL_PREFIX}$name' already exists."
        exit 1
    fi
    
    git checkout -b "${HOT_BRANCH}${REL_PREFIX}$name" "${PRD_BRANCH}"
    echo "✓ Branch '${HOT_BRANCH}${REL_PREFIX}$name' created from '$PRD_BRANCH'"
}

