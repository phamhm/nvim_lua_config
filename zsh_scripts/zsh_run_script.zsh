#!/usr/bin/env zsh
# Ensure at least one argument (the target script name) is provided
#
kitten @ set-tab-color active_fg="black" active_bg="#83d0c9" inactive_fg=pink inactive_bg=black

set_title() {
# \e]2; sets the window title, \a terminates the sequence
    print -Pn "\e]2;NV Running: $1\a"
}

print -Pn "\e]2;NVIM Running: $1\a"

if [[ -z "$1" ]]; then
    echo "Usage: $0 <script-name-or-path> [arguments...]"
    exit 1
fi
TARGET_SCRIPT="$1"
shift # Remove the script name from the argument list so remaining args pass through
# Check if the target script exists
if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo "Error: Script '$TARGET_SCRIPT' does not exist."
    exit 1
fi
# Check if the target script has execute permissions, or try to run it with zsh
if [[ ! -x "$TARGET_SCRIPT" ]]; then
    echo "Notice: '$TARGET_SCRIPT' is not marked executable. Running it with zsh directly..."
    zsh "$TARGET_SCRIPT" "$@"
else
    # Execute the script passing any remaining arguments
    "$TARGET_SCRIPT" "$@"
fi
