#!/usr/bin/env bash
set -euo pipefail

# Detect package manager
pm=""; if command -v apt >/dev/null 2>&1; then pm=apt; fi
if command -v dnf >/dev/null 2>&1; then pm=dnf; fi
if command -v pacman >/dev/null 2>&1; then pm=pacman; fi
if command -v brew >/dev/null 2>&1; then pm=brew; fi

# Core tools
case "$pm" in
  apt)
    sudo apt update
    sudo apt install -y zsh git curl fzf ripgrep fd-find bat eza direnv zoxide
    [ -x /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || true
    [ -x /usr/bin/batcat ] && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat || true
    ;;
  dnf)
    sudo dnf install -y zsh git curl fzf ripgrep fd-find bat eza direnv zoxide
    ;;
  pacman)
    sudo pacman -Syu --noconfirm zsh git curl fzf ripgrep fd bat eza direnv zoxide
    ;;
  brew)
    brew install zsh git curl fzf ripgrep fd bat eza direnv zoxide
    ;;
  *) echo "Install zsh, git, curl, fzf, ripgrep, fd, bat, eza, direnv, zoxide first."; exit 1;;
esac

# Make zsh the default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
  if command -v chsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" || echo "\nCould not chsh automatically; set your login shell to zsh manually."
  fi
fi

# Install Antidote (fast plugin manager)
mkdir -p "$HOME/.antidote"
if [ ! -d "$HOME/.antidote/antidote" ]; then
  git clone --depth=1 https://github.com/mattmc3/antidote "$HOME/.antidote/antidote"
fi

# Create plugin bundle list
cat > "$HOME/.zsh_plugins.txt" <<'PLUGINS'
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
Aloxaf/fzf-tab
romkatv/powerlevel10k
skywind3000/z.lua
PLUGINS

# Write the .zshrc
if [ -f "$HOME/.zshrc" ]; then cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"; fi
cat > "$HOME/.zshrc" <<'ZSHRC'
# ===== Fish-like Zsh config =====
fpath=(~/.antidote/antidote $fpath)
autoload -Uz antidote
if [[ ! -f ~/.zsh_plugins.zsh ]]; then
  antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh
fi
source ~/.zsh_plugins.zsh

setopt AUTO_CD AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME EXTENDED_GLOB GLOB_DOTS INTERACTIVE_COMMENTS CORRECT HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY
export HISTSIZE=100000 SAVEHIST=100000 HISTFILE="$HOME/.zsh_history"

export CLICOLOR=1 LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
alias ls='eza --group-directories-first --icons=auto'
alias ll='ls -lh'
alias la='ls -a'
alias cat='bat --paging=never'
[ -r ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"
alias cd='z'
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

zmodload zsh/complist
zstyle ':completion:*' menu select\ nzstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}%d%f'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --style=plain --color=always --line-range :200 --paging=never -- $realpath'

bindkey -e
bindkey '^[[Z' reverse-menu-complete
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Prompt
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
setopt GLOB_STAR_SHORT
alias reload!='source ~/.zshrc'
ZSHRC

if [ ! -f "$HOME/.p10k.zsh" ]; then
  curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/config/p10k-lean.zsh -o "$HOME/.p10k.zsh" || true
fi

printf "\n✅ Fish-like Zsh installed. Start a new terminal (or 'exec zsh') to use it.\n"
