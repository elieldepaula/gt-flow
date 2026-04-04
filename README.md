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

Set branches and sources:

```bash
# Global (all projects)
git config --global gt.prd-branch main
git config --global gt.dev-branch develop
git config --global gt.rel-branch release/
git config --global gt.fet-branch feature/
git config --global gt.hot-branch hotfix/
git config --global gt.rel-prefix ""
git config --global gt.prd-from dev
git config --global gt.dev-from dev

# Per repository
git config gt.prd-branch main
git config gt.dev-branch develop
git config gt.rel-branch release/
git config gt.fet-branch feature/
git config gt.hot-branch hotfix/
git config gt.rel-prefix ""
git config gt.fet-prefix ""
git config gt.prd-from dev
git config gt.dev-from dev
git config gt.keep-feature y
```

| Config | Values | Default | Description |
|--------|--------|---------|-------------|
| `gt.prd-branch` | Branch name | `main` | Production branch |
| `gt.dev-branch` | Branch name | `develop` | Development branch |
| `gt.rel-branch` | Branch name | `release/` | Release branch prefix |
| `gt.fet-branch` | Branch name | `feature/` | Feature branch prefix |
| `gt.hot-branch` | Branch name | `hotfix/` | Hotfix branch prefix |
| `gt.rel-prefix` | String | (empty) | Release name prefix |
| `gt.fet-prefix` | String | (empty) | Feature name prefix |
| `gt.prd-from` | `prd` or `dev` | `dev` | Source for PRD branches |
| `gt.dev-from` | `prd` or `dev` | `dev` | Source for DEV branches |
| `gt.keep-feature` | `y` or `n` | `y` | Remove feature branch after finish |

The `gt.prd-from` and `gt.dev-from` configs define the source branch for creating new feature and release branches:
- `prd`: Creates from `gt.prd-branch` (e.g., main)
- `dev`: Creates from `gt.dev-branch` (e.g., develop)

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
Create a new feature branch. The source branch depends on `gt.prd-from`.

```bash
gt feature new my-feature
# Creates: feature/my-feature from gt.prd-branch (if gt.prd-from=prd)
#          or from gt.dev-branch (if gt.prd-from=dev)

# With gt.fet-prefix:
gt feature new my-feature
# Creates: feature/prefix-my-feature (if gt.fet-prefix="prefix-")
```

### `gt feature finish <name>`
Merge the feature into the development branch.

```bash
gt feature finish my-feature
# Merges feature/my-feature into develop
# Checks out develop
```

To remove the feature branch after finish, set:
```bash
git config gt.keep-feature n
```

### `gt release new <name>`
Create a new release branch. The source branch depends on `gt.prd-from`.

```bash
gt release new 1.0.0
# Creates: release/1.0.0 from gt.prd-branch (if gt.prd-from=prd)
#          or from gt.dev-branch (if gt.prd-from=dev)
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

**Note:** The branch `<name>` branch is deleted.

### `gt hotfix new <name>`
Create a new hotfix branch from production branch.

```bash
gt hotfix new fix-login-bug
# Creates: hotfix/fix-login-bug from gt.prd-branch (main)
```

### `gt hotfix finish <name> <version>`
Finish a hotfix.

```bash
gt hotfix finish fix-login-bug 1.0.1
# 1. Merge into gt.prd-branch (main)
# 2. Merge into gt.dev-branch (develop)
# 3. Create tag <version>
# 4. Checkout to gt.dev-branch (develop)
```

**Note:** The branch `<name>` branch is deleted.

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

## License

MIT License

Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
