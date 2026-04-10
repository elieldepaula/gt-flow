#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/util.sh"

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

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' already exists."
        exit 1
    fi
    
    local source=$(get_source_branch "rel")
    git checkout -b "${REL_BRANCH}${REL_PREFIX}$name" "$source"
    echo "✓ Branch '${REL_BRANCH}${REL_PREFIX}$name' created from '$source'"
}

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

cmd_release_get() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release get"
    
    local branch="${REL_BRANCH}${REL_PREFIX}$name"
    
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
    
    echo "✓ Release '$branch' pulled from origin"
}

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

show_help() {
    echo "Usage: gt <command> [options]"
    echo ""
    echo "Commands:"
    echo "  log                     Show commit history"
    echo "  init                    Initialize git repository with '$PRD_BRANCH' and '$DEV_BRANCH'"
    echo "  feature new <name>      Create new feature branch (source: $PRD_FROM)"
    echo "  feature finish <name>   Merge feature into '$DEV_BRANCH'"
    echo "  feature send <name>     Push feature branch to remote"
    echo "  feature get <name>      Fetch and pull feature branch from remote"
    echo "  release new <name>      Create new release branch (source: $PRD_FROM)"
    echo "  release add <name>      Add feature to current release"
    echo "  release finish <name>   Finish release: merge into '$PRD_BRANCH', merge into '$DEV_BRANCH', and create tag"
    echo "  release send <name>     Push release branch to remote"
    echo "  release get <name>      Fetch and pull release branch from remote"
    echo "  hotfix new <name>       Create new hotfix branch (source: $PRD_BRANCH)"
    echo "  hotfix finish <name> <version>  Finish hotfix: merge into '$PRD_BRANCH', merge into '$DEV_BRANCH', and create tag"
    echo ""
    echo "Configuration (via git config):"
    echo "  gt.prd-branch=$PRD_BRANCH"
    echo "  gt.dev-branch=$DEV_BRANCH"
    echo "  gt.rel-branch=$REL_BRANCH"
    echo "  gt.fet-branch=$FET_BRANCH"
    echo "  gt.hot-branch=$HOT_BRANCH"
    echo "  gt.rel-prefix=$REL_PREFIX"
    echo "  gt.fet-prefix=$FET_PREFIX"
    echo "  gt.fet-from=$FET_FROM      (prd or dev)"
    echo "  gt.rel-from=$REL_FROM      (prd or dev)"
    echo "  gt.keep-feature=$KEEP_FEATURE    (y or n)"
    echo ""
    echo "To configure:"
    echo "  git config gt.prd-branch main"
    echo "  git config gt.dev-branch develop"
    echo "  git config gt.rel-branch release/"
    echo "  git config gt.fet-branch feature/"
    echo "  git config gt.hot-branch hotfix/"
    echo "  git config gt.rel-prefix \"\""
    echo "  git config gt.fet-prefix \"\""
    echo "  git config gt.fet-from dev   (or prd)"
    echo "  git config gt.rel-from dev   (or prd)"
    echo "  git config gt.keep-feature n (to remove feature branch after finish)"
}

case "$1" in
    "log")              cmd_log ;;
    "init")             cmd_init ;;
    "feature")
        case "$2" in
            "new")     cmd_feature_new "$3" ;;
            "finish")  cmd_feature_finish "$3" ;;
            "send")    cmd_feature_send "$3" ;;
            "get")     cmd_feature_get "$3" ;;
            *)         show_help ;;
        esac
        ;;
    "release")
        case "$2" in
            "new")     cmd_release_new "$3" ;;
            "add")     cmd_release_add "$3" ;;
            "finish")  cmd_release_finish "$3" ;;
            "send")    cmd_release_send "$3" ;;
            "get")     cmd_release_get "$3" ;;
            *)         show_help ;;
        esac
        ;;
    "hotfix")
        case "$2" in
            "new")     cmd_hotfix_new "$3" ;;
            "finish")  cmd_hotfix_finish "$3" "$4" ;;
            *)         show_help ;;
        esac
        ;;
    *)                 show_help ;;
esac
