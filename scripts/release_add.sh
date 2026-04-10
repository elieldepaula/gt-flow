#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_release_add() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release add"
    
    if ! is_release_branch; then
        echo "Error: Not on a release branch."
        exit 1
    fi
    
    if ! branch_exists "${FET_BRANCH}${FET_PREFIX}$name"; then
        echo "Error: Branch '${FET_BRANCH}${FET_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git merge "${FET_BRANCH}${FET_PREFIX}$name"
    echo "✓ Feature '${FET_BRANCH}${FET_PREFIX}$name' added to release"
}

