#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

PRD_BRANCH=$(git config gt.prd-branch || echo "main")
DEV_BRANCH=$(git config gt.dev-branch || echo "develop")
REL_BRANCH=$(git config gt.rel-branch || echo "release/")
FET_BRANCH=$(git config gt.fet-branch || echo "feature/")
HOT_BRANCH=$(git config gt.hot-branch || echo "hotfix/")
REL_PREFIX=$(git config gt.rel-prefix || echo "")
PRD_FROM=$(git config gt.prd-from || echo "dev")
DEV_FROM=$(git config gt.dev-from || echo "dev")
KEEP_FEATURE=$(git config gt.keep-feature || echo "y")
FET_PREFIX=$(git config gt.fet-prefix || echo "")

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
    local from=$(git config gt.${mode}-from || echo "prd")
    
    if [ "$from" = "dev" ]; then
        echo "$DEV_BRANCH"
    else
        echo "$PRD_BRANCH"
    fi
}

cmd_log() {
    is_git_repo
    git log --oneline --graph --all
}

cmd_init() {
    is_not_git_repo
    git init
    git branch -M "${PRD_BRANCH}"
    
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/

# IDE
.idea/
.vscode/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Environment
.env
.env.local

# Scripts
gt.sh
EOF
    
    git add .gitignore
    git commit -m "Initial commit"
    
    git checkout -b "${DEV_BRANCH}"
    echo "✓ Git repository initialized"
    echo "✓ Initial commit with .gitignore created"
    echo "✓ Branch '$DEV_BRANCH' created"
}

cmd_feature_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature new"
    
    if branch_exists "${FET_BRANCH}${FET_PREFIX}$name"; then
        echo "Error: Branch '${FET_BRANCH}${FET_PREFIX}$name' already exists."
        exit 1
    fi
    
    local source=$(get_source_branch "prd")
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

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' already exists."
        exit 1
    fi
    
    local source=$(get_source_branch "prd")
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

cmd_release_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release finish"
    
    if ! branch_exists "${REL_BRANCH}${REL_PREFIX}$name"; then
        echo "Error: Branch '${REL_BRANCH}${REL_PREFIX}$name' does not exist."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${REL_BRANCH}$name"
    
    git checkout "${DEV_BRANCH}"
    git merge "${REL_BRANCH}$name"
    
    git tag "$name"
    
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
    
    if branch_exists "${HOT_BRANCH}$name"; then
        echo "Error: Branch '${HOT_BRANCH}$name' already exists."
        exit 1
    fi
    
    git checkout -b "${HOT_BRANCH}$name" "${PRD_BRANCH}"
    echo "✓ Branch '${HOT_BRANCH}$name' created from '$PRD_BRANCH'"
}

cmd_hotfix_finish() {
    is_git_repo
    local name="$1"
    local version="$2"
    require_arg "$name" "hotfix finish"
    require_arg "$version" "hotfix finish"
    
    if ! branch_exists "${HOT_BRANCH}$name"; then
        echo "Error: Branch '${HOT_BRANCH}$name' does not exist."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${HOT_BRANCH}$name"
    
    git checkout "${DEV_BRANCH}"
    git merge "${HOT_BRANCH}$name"
    
    git tag "$version"
    
    git checkout "${DEV_BRANCH}"
    
    if git branch -d "${HOT_BRANCH}$name" &>/dev/null; then
        echo "✓ Hotfix '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag '$version' created, and branch removed"
    else
        echo "✓ Hotfix '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', tag '$version' created"
        echo "⚠ Branch '${HOT_BRANCH}$name' not removed (not fully merged)"
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
    echo "  release new <name>      Create new release branch (source: $PRD_FROM)"
    echo "  release add <name>      Add feature to current release"
    echo "  release finish <name>   Finish release: merge into '$PRD_BRANCH', merge into '$DEV_BRANCH', and create tag"
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
    echo "  gt.prd-from=$PRD_FROM      (prd or dev)"
    echo "  gt.dev-from=$DEV_FROM      (prd or dev)"
    echo "  gt.keep-feature=$KEEP_FEATURE     (y or n)"
    echo ""
    echo "To configure:"
    echo "  git config gt.prd-branch main"
    echo "  git config gt.dev-branch develop"
    echo "  git config gt.rel-branch release/"
    echo "  git config gt.fet-branch feature/"
    echo "  git config gt.hot-branch hotfix/"
    echo "  git config gt.rel-prefix \"\""
    echo "  git config gt.fet-prefix \"\""
    echo "  git config gt.prd-from dev   (or prd)"
    echo "  git config gt.dev-from dev   (or prd)"
    echo "  git config gt.keep-feature n   (to remove feature branch after finish)"
}

case "$1" in
    "log")              cmd_log ;;
    "init")             cmd_init ;;
    "feature")
        case "$2" in
            "new")     cmd_feature_new "$3" ;;
            "finish")  cmd_feature_finish "$3" ;;
            *)         show_help ;;
        esac
        ;;
    "release")
        case "$2" in
            "new")     cmd_release_new "$3" ;;
            "add")     cmd_release_add "$3" ;;
            "finish")  cmd_release_finish "$3" ;;
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
