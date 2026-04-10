#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_release_send() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release send"
    
    if ! branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git push origin "${REL_BRANCH}${REL_PREFIX}$name"
    echo "✓ Release '${REL_BRANCH}${REL_PREFIX}$name' pushed to origin"
}

