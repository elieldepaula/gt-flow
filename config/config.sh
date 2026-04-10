#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

PRD_BRANCH=$(git config gt.prd-branch || echo "main")
DEV_BRANCH=$(git config gt.dev-branch || echo "develop")
REL_BRANCH=$(git config gt.rel-branch || echo "release/")
FET_BRANCH=$(git config gt.fet-branch || echo "feature/")
HOT_BRANCH=$(git config gt.hot-branch || echo "hotfix/")
REL_PREFIX=$(git config gt.rel-prefix || echo "")
FET_FROM=$(git config gt.fet-from || echo "dev")
REL_FROM=$(git config gt.rel-from || echo "dev")
KEEP_FEATURE=$(git config gt.keep-feature || echo "y")
FET_PREFIX=$(git config gt.fet-prefix || echo "")


