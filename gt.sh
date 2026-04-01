#!/bin/bash

PRD_BRANCH=$(git config gt.prd-branch || echo "main")
DEV_BRANCH=$(git config gt.dev-branch || echo "develop")
REL_BRANCH="release"
FET_BRANCH="feature"

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
    echo "✓ Repositório git inicializado"
    echo "✓ Commit inicial com .gitignore criado"
    echo "✓ Branch '$DEV_BRANCH' criada"
}

cmd_feature_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature new"
    
    if branch_exists "${FET_BRANCH}/$name"; then
        echo "Erro: Branch '${FET_BRANCH}/$name' já existe."
        exit 1
    fi
    
    git checkout -b "${FET_BRANCH}/$name" "${PRD_BRANCH}"
    echo "✓ Branch '${FET_BRANCH}/$name' criada a partir de '$PRD_BRANCH'"
}

cmd_feature_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "feature finish"
    
    if ! branch_exists "${FET_BRANCH}/$name"; then
        echo "Erro: Branch '${FET_BRANCH}/$name' não existe."
        exit 1
    fi
    
    git checkout "${DEV_BRANCH}"
    git merge "${FET_BRANCH}/$name"
    echo "✓ Merge de '${FET_BRANCH}/$name' em '$DEV_BRANCH' realizado"
}

cmd_release_new() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release new"
    
    if branch_exists "${REL_BRANCH}/$name"; then
        echo "Erro: Branch '${REL_BRANCH}/$name' já existe."
        exit 1
    fi
    
    git checkout -b "${REL_BRANCH}/$name" "${PRD_BRANCH}"
    echo "✓ Branch '${REL_BRANCH}/$name' criada a partir de '$PRD_BRANCH'"
}

cmd_release_add() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release add"
    
    if ! is_release_branch; then
        echo "Erro: Você não está em uma branch de release."
        exit 1
    fi
    
    if ! branch_exists "${FET_BRANCH}/$name"; then
        echo "Erro: Branch '${FET_BRANCH}/$name' não existe."
        exit 1
    fi
    
    git merge "${FET_BRANCH}/$name"
    echo "✓ Feature '${FET_BRANCH}/$name' adicionada à release"
}

cmd_release_finish() {
    is_git_repo
    local name="$1"
    require_arg "$name" "release finish"
    
    if ! branch_exists "${REL_BRANCH}/$name"; then
        echo "Erro: Branch '${REL_BRANCH}/$name' não existe."
        exit 1
    fi
    
    git checkout "${PRD_BRANCH}"
    git merge "${REL_BRANCH}/$name"
    
    git checkout "${DEV_BRANCH}"
    git merge "${REL_BRANCH}/$name"
    
    git tag "$name"
    
    git checkout "${DEV_BRANCH}"
    echo "✓ Release '$name' finalizada: merge em '$PRD_BRANCH', merge em '$DEV_BRANCH' e tag criada"
}

show_help() {
    echo "Uso: gt <comando> [opções]"
    echo ""
    echo "Comandos:"
    echo "  log                     Exibir histórico de commits"
    echo "  init                    Inicializar repositório git com '$PRD_BRANCH' e '$DEV_BRANCH'"
    echo "  feature new <nome>      Criar nova branch de feature a partir de '$PRD_BRANCH'"
    echo "  feature finish <nome>    Fazer merge da feature em '$DEV_BRANCH'"
    echo "  release new <nome>       Criar nova branch de release a partir de '$PRD_BRANCH'"
    echo "  release add <nome>       Adicionar feature à release atual"
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
