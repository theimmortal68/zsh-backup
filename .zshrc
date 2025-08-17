# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===== Fish-like Zsh config =====
# Load Antidote plugin manager
fpath=(~/.antidote/antidote $fpath)
autoload -Uz antidote

# Build and source plugin bundle
if [[ ! -f ~/.zsh_plugins.zsh ]]; then
  antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh
fi
source ~/.zsh_plugins.zsh

# --- Options for fish-like behavior ---
setopt AUTO_CD            # 'cd' by just typing a directory
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME
setopt EXTENDED_GLOB GLOB_DOTS
setopt INTERACTIVE_COMMENTS
setopt CORRECT            # suggest fixes for mistyped commands
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY

# History settings
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="$HOME/.zsh_history"

# Colors & LS
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
alias ls='eza --group-directories-first --icons=auto'
alias ll='ls -lh'
alias la='ls -a'

# Better defaults
alias cat='bat --paging=never'

# fzf integration
[ -r ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide (smart cd)
eval "$(zoxide init zsh)"
alias cd='z'

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Completion styling like fish
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}%d%f'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# fzf-tab: show previews for files
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --style=plain --color=always --line-range :200 --paging=never -- $realpath'

# Prefix-only history search when there's text; normal up/down otherwise
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Use terminfo so it works across terminals
bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search  # Up arrow
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search # Down arrow

# Autosuggestions (accept with → like fish)
bindkey -e
bindkey '^[[Z' reverse-menu-complete           # Shift-Tab
# history substring search on arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Abbreviations (fish-like 'abbr')
# Examples; edit to taste. Type the short form; it expands on Enter.
abbr -S gco='git checkout'
abbr -S gst='git status'
abbr -S gdf='git diff'
abbr -S gp='git push'
abbr -S gpf='git push --force-with-lease'
abbr -S v='nvim'

# Prompt (Powerlevel10k). Run `p10k configure` anytime to tweak.
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Sensible PATH helpers
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Enable ** recursive globbing like fish's wildcard
setopt GLOB_STAR_SHORT

# Helper: reload config
alias reload!='source ~/.zshrc'

# Nice greeting (optional)
[[ -n "$ZELLIJ" || -n "$TMUX" ]] || echo "Welcome to Zsh ➜ $(uname -sr) — type 'p10k configure' to customize prompt."

# Ctrl+Right Arrow: Move cursor forward one word
bindkey "^[[1;5C" forward-word

# Ctrl+Left Arrow: Move cursor backward one word
bindkey "^[[1;5D" backward-word
