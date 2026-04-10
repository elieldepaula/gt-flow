#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_feature_send() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature send"
    
    if ! branch_exists "${FET_BRANCH}${FET_PREFIX}$name"; then
        echo "Error: Branch '${FET_BRANCH}${FET_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git push origin "${FET_BRANCH}${FET_PREFIX}$name"
    echo "✓ Feature '${FET_BRANCH}${FET_PREFIX}$name' pushed to origin"
}
