# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="eastwood"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias nvim="/opt/nvim-linux-x86_64/bin/nvim"
alias v="/opt/nvim-linux-x86_64/bin/nvim"
alias vim="/opt/nvim-linux-x86_64/bin/nvim"

alias update="sudo apt update && sudo apt upgrade"

if [ -z "$TMUX" ] && [ -z "$TERMINAL_EMULATOR" ] && [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
    tmux attach-session -t default 2>/dev/null || tmux new-session -s default
fi
