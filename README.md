# GT - Git Tool

CLI to automate Git tasks in the feature/release workflow.

## Installation

```bash
# Make script executable
chmod +x gt.sh

# Optional: add to PATH or create alias in your ~/.zshrc
alias gt='/path/to/gt.sh'
```

## Configuration

Set production and development branches:

```bash
# Global (all projects)
git config --global gt.prd-branch main
git config --global gt.dev-branch develop

# Per repository
git config gt.prd-branch main
git config gt.dev-branch develop
```

If not configured, defaults to: `main` and `develop`.

## Commands

### `gt log`
Show commit history in visual format.

```bash
gt log
```

### `gt init`
Initialize a Git repository with configured branches.

```bash
gt init
```
- Renames main branch to `gt.prd-branch`
- Creates `.gitignore` with common patterns
- Creates initial commit
- Creates branch `gt.dev-branch` and checks it out

### `gt feature new <name>`
Create a new feature branch from the production branch.

```bash
gt feature new my-feature
# Creates: feature/my-feature from main
```

### `gt feature finish <name>`
Merge the feature into the development branch.

```bash
gt feature finish my-feature
# Merges feature/my-feature into develop
# Checks out develop
```

### `gt release new <name>`
Create a new release branch from the production branch.

```bash
gt release new 1.0.0
# Creates: release/1.0.0 from main
```

### `gt release add <name>`
Add a feature to the current release.

```bash
# While on release/1.0.0 branch
gt release add my-feature
# Merges feature/my-feature into current release
```

### `gt release finish <name>`
Finish a release.

```bash
gt release finish 1.0.0
# 1. Merge into gt.prd-branch (main)
# 2. Merge into gt.dev-branch (develop)
# 3. Create tag <name>
# 4. Checkout to gt.dev-branch (develop)
```

## Workflow

```
gt init
                           # Create features
gt feature new login
# ... work ...
gt feature new dashboard
# ... work ...

                           # Create release
gt release new 1.0.0
gt release add login       # Add feature to release
gt release add dashboard    # Add feature to release
# ... final adjustments ...

gt release finish 1.0.0
```

## Help

```bash
gt
# Shows all commands and current configuration
```
