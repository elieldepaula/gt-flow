#!/bin/bash

PRD_BRANCH=$(git config gt.prd-branch || echo "main")
DEV_BRANCH=$(git config gt.dev-branch || echo "develop")
REL_BRANCH=$(git config gt.rel-branch || echo "release")
FET_BRANCH=$(git config gt.fet-branch || echo "feature")

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
    [[ "$current" == "${REL_BRANCH}"/* ]]
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
    
    if branch_exists "${FET_BRANCH}/$name"; then
        echo "Error: Branch '${FET_BRANCH}/$name' already exists."
        exit 1
    fi
    
    git checkout -b "${FET_BRANCH}/$name" "${PRD_BRANCH}"
    echo "✓ Branch '${FET_BRANCH}/$name' created from '$PRD_BRANCH'"
}

cmd_feature_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature finish"
    
    if ! branch_exists "${FET_BRANCH}/$name"; then
        echo "Error: Branch '${FET_BRANCH}/$name' does not exist."
        exit 1
    fi
    
    git checkout "${DEV_BRANCH}"
    git merge "${FET_BRANCH}/$name"
    echo "✓ Merged '${FET_BRANCH}/$name' into '$DEV_BRANCH'"
}

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "${REL_BRANCH}/$name"; then
        echo "Error: Branch '${REL_BRANCH}/$name' already exists."
        exit 1
    fi
    
    git checkout -b "${REL_BRANCH}/$name" "${PRD_BRANCH}"
    echo "✓ Branch '${REL_BRANCH}/$name' created from '$PRD_BRANCH'"
}

cmd_release_add() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release add"
    
    if ! is_release_branch; then
        echo "Error: Not on a release branch."
        exit 1
    fi
    
    if ! branch_exists "${FET_BRANCH}/$name"; then
        echo "Error: Branch '${FET_BRANCH}/$name' does not exist."
        exit 1
    fi
    
    git merge "${FET_BRANCH}/$name"
    echo "✓ Feature '${FET_BRANCH}/$name' added to release"
}

cmd_release_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release finish"
    
    if ! branch_exists "${REL_BRANCH}/$name"; then
        echo "Error: Branch '${REL_BRANCH}/$name' does not exist."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${REL_BRANCH}/$name"
    
    git checkout "${DEV_BRANCH}"
    git merge "${REL_BRANCH}/$name"
    
    git tag "$name"
    
    git checkout "${DEV_BRANCH}"
    echo "✓ Release '$name' finished: merged into '$PRD_BRANCH', merged into '$DEV_BRANCH', and tag created"
}

show_help() {
    echo "Usage: gt <command> [options]"
    echo ""
    echo "Commands:"
    echo "  log                     Show commit history"
    echo "  init                    Initialize git repository with '$PRD_BRANCH' and '$DEV_BRANCH'"
    echo "  feature new <name>      Create new feature branch from '$PRD_BRANCH'"
    echo "  feature finish <name>   Merge feature into '$DEV_BRANCH'"
    echo "  release new <name>      Create new release branch from '$PRD_BRANCH'"
    echo "  release add <name>      Add feature to current release"
    echo "  release finish <name>   Finish release: merge into '$PRD_BRANCH', merge into '$DEV_BRANCH', and create tag"
    echo ""
    echo "Configuration (via git config):"
    echo "  gt.prd-branch=$PRD_BRANCH"
    echo "  gt.dev-branch=$DEV_BRANCH"
    echo ""
    echo "To configure:"
    echo "  git config gt.prd-branch main"
    echo "  git config gt.dev-branch develop"
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
    *)                 show_help ;;
esac
