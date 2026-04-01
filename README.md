# GT - Git Tool

CLI para automatizar tarefas do Git no fluxo de trabalho feature/release.

## Instalação

```bash
# Torne o script executável
chmod +x gt.sh

# Opcional: adicione ao PATH ou crie um alias no seu ~/.zshrc
alias gt='/caminho/para/gt.sh'
```

## Configuração

Defina as branches de produção e desenvolvimento:

```bash
# Global (todos os projetos)
git config --global gt.prd-branch main
git config --global gt.dev-branch develop

# Por repositório
git config gt.prd-branch main
git config gt.dev-branch develop
```

Se não configurado, usa os padrões: `main` e `develop`.

## Comandos

### `gt init`
Inicializa um repositório Git com as branches configuradas.

```bash
gt init
```
- Renomeia branch principal para `gt.prd-branch`
- Cria `.gitignore` com padrões comuns
- Cria commit inicial
- Cria branch `gt.dev-branch` e faz checkout

### `gt log`
Exibe o histórico de commits em formato visual.

```bash
gt log
```

### `gt feature new <nome>`
Cria uma nova branch de feature a partir da branch de produção.

```bash
gt feature new minha-feature
# Cria: feature/minha-feature a partir de main
```

### `gt feature finish <nome>`
Faz merge da feature na branch de desenvolvimento.

```bash
gt feature finish minha-feature
# Faz merge de feature/minha-feature em develop
# Faz checkout para develop
```

### `gt release new <nome>`
Cria uma nova branch de release a partir da branch de produção.

```bash
gt release new 1.0.0
# Cria: release/1.0.0 a partir de main
```

### `gt release add <nome>`
Adiciona uma feature à release atual.

```bash
# Estando na branch release/1.0.0
gt release add minha-feature
# Faz merge de feature/minha-feature na release atual
```

### `gt release finish <nome>`
Finaliza uma release.

```bash
gt release finish 1.0.0
# 1. Merge em gt.prd-branch (main)
# 2. Merge em gt.dev-branch (develop)
# 3. Cria tag <nome>
# 4. Faz checkout para gt.dev-branch (develop)
```

## Fluxo de Trabalho

```
gt init
                           # Criar features
gt feature new login
# ... trabalho ...
gt feature new dashboard
# ... trabalho ...

                           # Criar release
gt release new 1.0.0
gt release add login       # Adiciona feature à release
gt release add dashboard    # Adiciona feature à release
# ... ajustes finais ...

gt release finish 1.0.0
```

## Ajuda

```bash
gt
# Exibe todos os comandos e configuração atual
```
