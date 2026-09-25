set-option -g status-position top
bind r source-file ~/.tmux.conf
set-option -sg escape-time 10
set -g default-terminal "screen-256color"
#set-option -sa terminal-overrides ",alacritty:RGB"
set-option -g renumber-windows on

unbind C-b
set-option -g prefix C-t
bind-key C-t send-prefix

# split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window      -c "#{pane_current_path}"
unbind '"'
unbind %

# Enable mouse mode (tmux 2.1 and above)
set -g mouse on

set -g status-bg black
set -g status-fg white

set -g status-right '{#S} #H  '
set -g status-left ''

set -g status-left-length 20
setw -g mode-keys vi

setw -g window-status-current-style 'fg=black bg=cyan'
setw -g window-status-current-format '[#I:#W#F]'

setw -g window-status-style 'fg=grey bg=black'
setw -g window-status-format '#I:#W#F'

set-option -g history-limit 5000

set -g base-index 1
setw -g pane-base-index 1

set -g default-command /usr/bin/zsh
set -g default-shell /usr/bin/zsh

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# panes
set -g pane-border-style 'fg=red'
set -g pane-active-border-style 'fg=yellow'
