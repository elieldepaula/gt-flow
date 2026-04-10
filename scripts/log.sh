#!/bin/bash

# Copyright (c) 2026 Eliel de Paula <ulisse.falcucci@gmail.com>
# Licensed under the MIT License

cmd_log() {
    is_git_repo
    git log --graph --all
}

