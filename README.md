# GT - Git Tool

CLI to automate Git tasks in feature/release/hotfix workflows.

---

## Installation

```bash
# Clone or copy the project to a directory
git clone <repo-url> ~/gt-tool

# Make script executable
chmod +x ~/gt-tool/bin/gt.sh

# Add alias to ~/.zshrc or ~/.bashrc
alias gt='~/gt-tool/bin/gt.sh'

# Reload terminal
source ~/.zshrc
```

---

## Configuration

### Branch Configuration

| Config | Default | Description |
|--------|---------|-------------|
| `gt.prd-branch` | `main` | Production branch |
| `gt.dev-branch` | `develop` | Development branch |
| `gt.rel-branch` | `release/` | Release branch prefix |
| `gt.fet-branch` | `feature/` | Feature branch prefix |
| `gt.hot-branch` | `hotfix/` | Hotfix branch prefix |

### Prefix Configuration

| Config | Default | Description |
|--------|---------|-------------|
| `gt.rel-prefix` | (empty) | Custom prefix for release names |
| `gt.fet-prefix` | (empty) | Custom prefix for feature names |

### Source Configuration

| Config | Default | Description |
|--------|---------|-------------|
| `gt.fet-from` | `dev` | Source for feature branches (`dev` or `prd`) |
| `gt.rel-from` | `dev` | Source for release branches (`dev` or `prd`) |

### Other Configuration

| Config | Default | Description |
|--------|---------|-------------|
| `gt.keep-feature` | `y` | Keep feature branch after finish (`y` or `n`) |

### Configuration Examples

```bash
# Global (all projects)
git config --global gt.prd-branch main
git config --global gt.dev-branch develop
git config --global gt.fet-from dev

# Per repository
git config gt.rel-prefix "v"
git config gt.fet-prefix "TEAM-"
git config gt.keep-feature n
```

---

## Commands

### Log

```bash
gt log
```
Show commit history in visual format.

---

### Init

```bash
gt init
```
Initialize a Git repository with standard structure:
- Renames main branch to `gt.prd-branch`
- Creates `.gitignore` with common patterns
- Creates initial commit
- Creates and switches to `gt.dev-branch`

---

### Feature

| Command | Description |
|---------|-------------|
| `gt feature new <name>` | Create a new feature branch |
| `gt feature finish <name>` | Merge feature into development branch |
| `gt feature send <name>` | Push feature branch to remote |
| `gt feature get <name>` | Fetch and checkout feature from remote |

**Example:**
```bash
gt feature new login
gt feature send login
gt feature finish login
```

---

### Release

| Command | Description |
|---------|-------------|
| `gt release new <name>` | Create a new release branch |
| `gt release add <name>` | Add a feature to current release |
| `gt release finish <name>` | Finish release |
| `gt release send <name>` | Push release branch to remote |
| `gt release get <name>` | Fetch and checkout release from remote |

**Example:**
```bash
gt release new 1.0.0
gt release add login
gt release add dashboard
gt release finish 1.0.0
```

---

### Hotfix

| Command | Description |
|---------|-------------|
| `gt hotfix new <name>` | Create a new hotfix branch (from `prd-branch`) |
| `gt hotfix finish <name> <version>` | Finish hotfix with specific version |

**Example:**
```bash
gt hotfix new fix-login-bug
gt hotfix finish fix-login-bug 1.0.1
```

---

## Workflow

```
Feature Workflow
────────────────

gt feature new login
gt feature new dashboard
gt feature new api-users

... work ...

gt feature finish login
gt feature finish dashboard
gt feature finish api-users


Release Workflow
──────────────

gt release new 1.0.0
gt release add login
gt release add dashboard
gt release add api-users
... final adjustments ...
gt release finish 1.0.0


Hotfix Workflow
──────────────

gt hotfix new critical-bug
... work ...
gt hotfix finish critical-bug 1.0.1
```

---

## Help

```bash
gt
```
Show all available commands and current configuration.

---

## License

MIT License

Copyright (c) 2026 Eliel de Paula
