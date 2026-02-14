# Claude Code Status Line

A custom status line script for [Claude Code](https://claude.com/claude-code) that enhances your terminal experience with rich contextual information.

## Features

This status line script displays:

- **Current Working Directory** - Shows your current path (with `~` for home directory)
- **Current Time** - Displays time in HH:MM:SS format
- **Git Information** - Shows branch name and change indicators:
  - Red dot (`●`) - Unstaged changes
  - Green dot (`●`) - Staged changes
- **Context Window Stats** - Displays:
  - Model ID (e.g., `claude-sonnet-4-5`)
  - Token usage with decimal precision for hundreds (e.g., `45k.5k/200k`)
  - Used percentage

## Screenshot

Example status line output:
```
~/work/my-project [15:30:45] [±main ●●] [claude-sonnet-4-5 | 45k.5k/200k, 22%]
```

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI installed
- `jq` - JSON processor for parsing input
  ```bash
  # macOS
  brew install jq

  # Ubuntu/Debian
  sudo apt-get install jq

  # Other platforms - see https://stedolan.github.io/jq/download/
  ```
- Git (optional, for git information display)

## Installation

### 1. Clone or Download the Script

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-code-status-line.git
cd claude-code-status-line

# Or download just the script
curl -O https://raw.githubusercontent.com/yourusername/claude-code-status-line/master/statusline-command.sh
chmod +x statusline-command.sh
```

### 2. Move to a Permanent Location

```bash
# Create a directory for custom scripts (if it doesn't exist)
mkdir -p ~/.local/bin

# Move the script
mv statusline-command.sh ~/.local/bin/

# Make it executable
chmod +x ~/.local/bin/statusline-command.sh
```

### 3. Configure Claude Code

Edit your Claude Code settings file to use the custom status line:

```bash
# Open Claude Code settings
# Location: ~/.claude/settings.json
```

Add or update the `statusline_command` setting:

```json
{
  "statusline_command": "~/.local/bin/statusline-command.sh"
}
```

**Alternative paths:**
- If you keep scripts elsewhere: Use the full path (e.g., `/Users/yourname/scripts/statusline-command.sh`)
- If using the repository directly: Point to the script in the cloned repo

### 4. Restart Claude Code

Restart your Claude Code session to see the new status line in action.

## How It Works

The script receives JSON input from Claude Code via stdin containing:
- Workspace information (current directory)
- Model details (model ID)
- Context window statistics (context size, used percentage)

It processes this data and outputs a formatted status line with:
- **Color coding**: Different colors for different information types
- **Git status detection**: Checks for staged/unstaged changes
- **Performance optimization**: Uses Git flags to skip optional locks (`fsmonitor=false`)
- **Smart formatting**: Token display with decimal precision (e.g., `45k.5k` for 45,500 tokens)

## Customization

You can modify `statusline-command.sh` to customize:

### Change Colors

The script uses ANSI color codes:
- `\033[1m` - Bold
- `\033[36m` - Cyan (context info)
- `\033[32m` - Green (git branch symbol)
- `\033[1;32m` - Bold green (staged changes)
- `\033[1;31m` - Bold red (unstaged changes)
- `\033[0m` - Reset

### Add More Information

You can extract additional data from the JSON input. Available fields include:
```bash
# See all available data
echo "$input" | jq '.'
```

Common fields used by the script:
- `.workspace.current_dir` - Current directory
- `.model.id` - Model identifier
- `.context_window.context_window_size` - Maximum context size
- `.context_window.used_percentage` - Percentage of context used

### Change Time Format

Modify line 4 to use a different date format:
```bash
time=$(date "+%H:%M:%S")  # Current: 24-hour format
time=$(date "+%I:%M %p")   # 12-hour format with AM/PM
time=$(date "+%Y-%m-%d %H:%M")  # Include date
```

### Token Display Precision

The script shows token usage with decimal precision:
- `45k/200k` - Exact thousands (45,000 tokens)
- `45k.5k/200k` - With hundreds (45,500 tokens)

To remove decimal precision, modify lines 10 and 14:
```bash
# Remove this line:
tokens_dec=$((tokens_total / 100 % 10))

# And simplify the printf to remove the .$tokens_dec reference
```

## Troubleshooting

### Status line not appearing
- Verify the script path in `~/.claude/settings.json` is correct
- Ensure the script is executable: `chmod +x /path/to/statusline-command.sh`
- Check that `jq` is installed: `which jq`

### Git information not showing
- Ensure you're in a git repository
- Check that git is installed and in your PATH

### Permission errors
- The script needs read access to your git repository
- Ensure the script file has execute permissions

### Colors not displaying correctly
- Your terminal must support ANSI color codes
- Most modern terminals (iTerm2, Terminal.app, VSCode terminal) support this by default

## Contributing

Contributions are welcome! Feel free to:
- Report bugs or issues
- Suggest new features
- Submit pull requests
- Share your customizations

## License

MIT License - Feel free to use and modify as needed.

## Links

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [jq Manual](https://stedolan.github.io/jq/manual/)

## Inspiration

This script was created to enhance the Claude Code experience with rich, at-a-glance contextual information similar to popular shell prompts like Starship and Oh My Zsh.
