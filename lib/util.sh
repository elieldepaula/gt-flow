#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

is_git_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: Not a git repository."
        exit 1
    fi
}

is_not_git_repo() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: Git repository already exists."
        exit 1
    fi
}

require_arg() {
    if [ -z "$1" ]; then
        echo "Error: Argument '<name>' is required."
        echo "Usage: gt $1 <name>"
        exit 1
    fi
}

branch_exists() {
    git rev-parse --verify "$1" &>/dev/null
}

get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

is_release_branch() {
    local current=$(get_current_branch)
    [[ "$current" == "${REL_BRANCH}"* ]]
}

is_hotfix_branch() {
    local current=$(get_current_branch)
    [[ "$current" == "${HOT_BRANCH}"* ]]
}

get_source_branch() {
    local mode="$1"
    local from=$(git config gt.${mode}-from || echo "dev")
    
    if [ "$from" = "dev" ]; then
        echo "$DEV_BRANCH"
    else
        echo "$PRD_BRANCH"
    fi
}

