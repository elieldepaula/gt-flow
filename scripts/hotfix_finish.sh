#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_hotfix_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "hotfix finish"
    
    if ! branch_exists "${HOT_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${HOT_BRANCH${REL_PREFIX}}$name' does not exist."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${HOT_BRANCH}${REL_PREFIX}$name"

    git tag "$name"

    git checkout "${DEV_BRANCH}"
    git merge "${HOT_BRANCH}${REL_PREFIX}$name"

    git checkout "${DEV_BRANCH}"

    if git branch -d "${HOT_BRANCH}${REL_PREFIX}$name" &>/dev/null; then
        echo "✓ Hotfix '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag '$version' created, and branch removed"
    else
        echo "✓ Hotfix '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag '$version' created"
        echo "⚠ Branch '${HOT_BRANCH}${REL_PREFIX}$name' not removed (not fully merged)"
    fi
}

