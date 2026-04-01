#!/bin/bash

PRD_BRANCH=$(git config gt.prd-branch || echo "main")
DEV_BRANCH=$(git config gt.dev-branch || echo "develop")

is_git_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Erro: Você não está em um repositório git."
        exit 1
    fi
}

is_not_git_repo() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Erro: Já existe um repositório git neste diretório."
        exit 1
    fi
}

require_arg() {
    if [ -z "$1" ]; then
        echo "Erro: Argumento '<nome>' é obrigatório."
        echo "Uso: gt $1 <nome>"
        exit 1
    fi
}

branch_exists() {
    git rev-parse --verify "$1" &>/dev/null
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
    echo "✓ Repositório git inicializado"
    echo "✓ Commit inicial com .gitignore criado"
    echo "✓ Branch '$DEV_BRANCH' criada"
}

cmd_feature_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature new"
    
    if branch_exists "feature/$name"; then
        echo "Erro: Branch 'feature/$name' já existe."
        exit 1
    fi
    
    git checkout -b "feature/$name" "${PRD_BRANCH}"
    echo "✓ Branch 'feature/$name' criada a partir de '$PRD_BRANCH'"
}

cmd_feature_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature finish"
    
    if ! branch_exists "feature/$name"; then
        echo "Erro: Branch 'feature/$name' não existe."
        exit 1
    fi
    
    git checkout "${DEV_BRANCH}"
    git merge "feature/$name"
    echo "✓ Merge de 'feature/$name' em '$DEV_BRANCH' realizado"
}

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "release/$name"; then
        echo "Erro: Branch 'release/$name' já existe."
        exit 1
    fi
    
    git checkout -b "release/$name" "${PRD_BRANCH}"
    echo "✓ Branch 'release/$name' criada a partir de '$PRD_BRANCH'"
}

cmd_release_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release finish"
    
    if ! branch_exists "release/$name"; then
        echo "Erro: Branch 'release/$name' não existe."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "release/$name"
    
    git checkout "${DEV_BRANCH}"
    git merge "release/$name"
    
    git tag "$name"
    
    git checkout "${DEV_BRANCH}"
    echo "✓ Release '$name' finalizada: merge em '$PRD_BRANCH', merge em '$DEV_BRANCH' e tag criada"
}

show_help() {
    echo "Uso: gt <comando> [opções]"
    echo ""
    echo "Comandos:"
    echo "  init                    Inicializar repositório git com '$PRD_BRANCH' e '$DEV_BRANCH'"
    echo "  feature new <nome>      Criar nova branch de feature a partir de '$PRD_BRANCH'"
    echo "  feature finish <nome>   Fazer merge da feature em '$DEV_BRANCH'"
    echo "  release new <nome>      Criar nova branch de release a partir de '$PRD_BRANCH'"
    echo "  release finish <nome>   Finalizar release: merge em '$PRD_BRANCH', merge em '$DEV_BRANCH' e criar tag"
    echo ""
    echo "Configurações (via git config):"
    echo "  gt.prd-branch=$PRD_BRANCH"
    echo "  gt.dev-branch=$DEV_BRANCH"
    echo ""
    echo "Para configurar:"
    echo "  git config gt.prd-branch main"
    echo "  git config gt.dev-branch develop"
}

case "$1" in
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
            "finish")  cmd_release_finish "$3" ;;
            *)         show_help ;;
        esac
        ;;
    *)                 show_help ;;
esac
