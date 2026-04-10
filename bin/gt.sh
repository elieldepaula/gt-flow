#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/util.sh"

for file in "$ROOT_DIR/scripts/"*.sh; do
    source "$file"
done

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
