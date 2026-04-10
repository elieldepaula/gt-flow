#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_feature_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature finish"
    
    if ! branch_exists "${FET_BRANCH}${FET_PREFIX}$name"; then
        echo "Error: Branch '${FET_BRANCH}${FET_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git checkout "${DEV_BRANCH}"
    git merge "${FET_BRANCH}${FET_PREFIX}$name"
    
    if [ "$KEEP_FEATURE" = "n" ]; then
        if git branch -d "${FET_BRANCH}${FET_PREFIX}$name" &>/dev/null; then
            echo "✓ Merged '${FET_BRANCH}${FET_PREFIX}$name' into '$DEV_BRANCH' and branch removed"
        else
            echo "✓ Merged '${FET_BRANCH}${FET_PREFIX}$name' into '$DEV_BRANCH'"
            echo "⚠ Branch '${FET_BRANCH}${FET_PREFIX}$name' not removed (not fully merged)"
        fi
    else
        echo "✓ Merged '${FET_BRANCH}${FET_PREFIX}$name' into '$DEV_BRANCH'"
    fi
}
