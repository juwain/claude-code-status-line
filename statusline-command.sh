#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
time=$(date "+%H:%M:%S")
model_id=$(echo "$input" | jq -r '.model.id // ""')

# Replace home directory with ~
cwd="${cwd/#$HOME/~}"

# Context statistics
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Format context info (total tokens and percentage)
tokens_total=$((input_tokens + output_tokens))
if [ "$tokens_total" -gt 0 ]; then
    if [ -n "$model_id" ]; then
        context_info=$(printf " \033[36m[%s | %sk/%sk, %s%%]\033[0m" "$model_id" "$((tokens_total/1000))" "$((context_size/1000))" "$used_pct")
    else
        context_info=$(printf " \033[36m[%sk/%sk, %s%%]\033[0m" "$((tokens_total/1000))" "$((context_size/1000))" "$used_pct")
    fi
else
    context_info=""
fi

# Git information (skip optional locks for performance)
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false branch --show-current 2>/dev/null || echo "HEAD")

    # Check for staged and unstaged changes
    staged=""
    unstaged=""

    if git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false diff --cached --quiet 2>/dev/null; then
        : # no staged changes
    else
        staged=$(printf "\033[1;32m●\033[0m")  # green bold dot
    fi

    if git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false diff --quiet 2>/dev/null; then
        : # no unstaged changes
    else
        unstaged=$(printf "\033[1;31m●\033[0m")  # red bold dot
    fi

    # Build git info string
    git_info=$(printf " [\033[32m±\033[1m%s\033[0m %s%s\033[0m]" "$branch" "$unstaged" "$staged")
fi

# Output the status line (dimmed colors will be applied by the terminal)
printf "\033[1m%s\033[0m [%s]%s%s" "$cwd" "$time" "$git_info" "$context_info"
