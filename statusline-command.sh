#!/bin/bash
input=$(cat)
cwd=$(jq -r '.workspace.current_dir' <<< "$input")
time=$(date "+%H:%M:%S")
model_id=$(jq -r '.model.id // ""' <<< "$input")
context_size=$(jq -r '.context_window.context_window_size // 0' <<< "$input")
used_pct=$(jq -r '.context_window.used_percentage // 0' <<< "$input")
tokens_total=$((context_size * used_pct / 100))
tokens_k=$((tokens_total / 1000))
tokens_dec=$((tokens_total / 100 % 10))
context_info=$(
    if [ "$tokens_total" -gt 0 ]; then
        if [ "$tokens_dec" -gt 0 ]; then
            printf " \033[36m[%s | %sk.%sk/%sk, %s%%]\033[0m" "$model_id" "$tokens_k" "$tokens_dec" "$((context_size/1000))" "$used_pct"
        else
            printf " \033[36m[%s | %sk/%sk, %s%%]\033[0m" "$model_id" "$tokens_k" "$((context_size/1000))" "$used_pct"
        fi
    fi
)
git_info=$(
    if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
        branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false branch --show-current 2>/dev/null || echo "HEAD")
        staged="" unstaged=""
        git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false diff --cached --quiet 2>/dev/null || staged=$'\033[1;32m●\033[0m'
        git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false diff --quiet 2>/dev/null || unstaged=$'\033[1;31m●\033[0m'
        printf " [\033[32m±\033[1m%s\033[0m %s%s]" "$branch" "$unstaged" "$staged"
    fi
)
printf "\033[1m%s\033[0m [%s]%s%s\n" "${cwd/#$HOME/~}" "$time" "$git_info" "$context_info"
