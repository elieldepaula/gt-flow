#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

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
