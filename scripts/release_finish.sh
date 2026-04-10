#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_release_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release finish"
    
    if ! branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${REL_BRANCH}${REL_PREFIX}$name"
    
    git tag "$name"

    git checkout "${DEV_BRANCH}"
    git merge "${REL_BRANCH}${REL_PREFIX}$name"

    git checkout "${DEV_BRANCH}"

    if git branch -d "${REL_BRANCH}${REL_PREFIX}$name" &>/dev/null; then
        echo "✓ Release '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag created, and branch removed"
    else
        echo "✓ Release '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag created"
        echo "⚠ Branch '${REL_BRANCH}${REL_PREFIX}$name' not removed (not fully merged)"
    fi
}
