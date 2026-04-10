#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

CURRENT_VERSION=1.0.0
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/util.sh"
source "$ROOT_DIR/lib/update.sh"

for file in "$ROOT_DIR/scripts/"*.sh; do
    source "$file"
done

case "$1" in
    "log")              cmd_log ;;
    "init")             cmd_init ;;
    "update")           cmd_update_check ;;
    "feature")
        case "$2" in
            "new")     cmd_feature_new "$3" ;;
            "finish")  cmd_feature_finish "$3" ;;
            "send")    cmd_feature_send "$3" ;;
            "get")     cmd_feature_get "$3" ;;
            *)         show_help ;;
        esac
        ;;
    "release")
        case "$2" in
            "new")     cmd_release_new "$3" ;;
            "add")     cmd_release_add "$3" ;;
            "finish")  cmd_release_finish "$3" ;;
            "send")    cmd_release_send "$3" ;;
            "get")     cmd_release_get "$3" ;;
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
