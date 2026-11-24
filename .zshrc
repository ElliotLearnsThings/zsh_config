# ~/.zshrc — native zsh, no oh-my-zsh / starship
# Palette: Tokyo Night (Omarchy default)

# ── Environment ──────────────────────────────────────────────
export EDITOR=nvim VISUAL=nvim PAGER=less
export LANG=${LANG:-en_US.UTF-8}
typeset -U path
path=($HOME/.local/bin $HOME/bin $HOME/go/bin $HOME/.cargo/bin $path)
# inside proot Debian: drop Termux's bin so its android-built node etc. don't leak in
path=(${path:#/data/data/com.termux/*})
# nvm (lazy: only loads when you first call node/npm/npx/nvm, keeps startup fast)
export NVM_DIR=$HOME/.nvm
if [[ -s $NVM_DIR/nvm.sh ]]; then
  _nvm_default=($NVM_DIR/versions/node/*(N/om[1]))
  [[ -n $_nvm_default ]] && path=($_nvm_default/bin $path)
  nvm() { unfunction nvm; source $NVM_DIR/nvm.sh; nvm "$@" }
fi

# ── History ──────────────────────────────────────────────────
HISTFILE=~/.zsh_history HISTSIZE=50000 SAVEHIST=50000
setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks \
       share_history extended_history inc_append_history
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments \
       no_beep prompt_subst

# ── Completion ───────────────────────────────────────────────
autoload -Uz compinit && compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{#565f89}-- %d --%f'
zmodload zsh/complist

# ── Vi mode ──────────────────────────────────────────────────
bindkey -v
export KEYTIMEOUT=1
bindkey -v '^?' backward-delete-char
bindkey '^R' history-incremental-search-backward
bindkey -M menuselect 'h' vi-backward-char 'j' vi-down-line-or-history \
                      'k' vi-up-line-or-history 'l' vi-forward-char
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# beam cursor in insert, block in normal; prompt char follows mode
VI_MODE=ins
zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then VI_MODE=cmd; print -n '\e[2 q'
  else VI_MODE=ins; print -n '\e[6 q'; fi
  zle reset-prompt
}
zle-line-init() { VI_MODE=ins; print -n '\e[6 q' }
zle -N zle-keymap-select; zle -N zle-line-init

# ── Prompt ───────────────────────────────────────────────────
# left:  [duration] [user@host over ssh] ❯   (red on error, ❮ in normal mode)
# right: dir  branch status  venv
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{#9ece6a}+%f'
zstyle ':vcs_info:git:*' unstagedstr '%F{#e0af68}!%f'
zstyle ':vcs_info:git:*' formats ' %F{#bb9af7} %b%f%c%u%m'
zstyle ':vcs_info:git:*' actionformats ' %F{#bb9af7} %b%f %F{#f7768e}(%a)%f%c%u%m'
zstyle ':vcs_info:git*+set-message:*' hooks git-extra
+vi-git-extra() {
  [[ -n $(git ls-files --others --exclude-standard --directory 2>/dev/null | head -1) ]] \
    && hook_com[misc]+='%F{#7dcfff}?%f'
  local ab=($(git rev-list --left-right --count HEAD...@{u} 2>/dev/null))
  (( ${ab[1]:-0} )) && hook_com[misc]+=" %F{#7dcfff}⇡${ab[1]}%f"
  (( ${ab[2]:-0} )) && hook_com[misc]+=" %F{#7dcfff}⇣${ab[2]}%f"
}

_cmd_start=0 _cmd_dur=''
_prompt_preexec() { _cmd_start=$EPOCHREALTIME }
_prompt_precmd() {
  vcs_info
  _cmd_dur=''
  if (( _cmd_start )); then
    local d=$(( EPOCHREALTIME - _cmd_start ))
    (( d >= 3 )) && _cmd_dur="%F{#e0af68}$( (( d >= 60 )) && printf '%dm%ds' $((d/60)) $((d%60)) || printf '%.1fs' $d)%f "
    _cmd_start=0
  fi
  print   # blank line between commands
}
zmodload zsh/datetime
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd  _prompt_precmd

_ssh_host() { [[ -n $SSH_CONNECTION ]] && print -n '%F{#7dcfff}%n@%m%f ' }
_venv() { [[ -n $VIRTUAL_ENV ]] && print -n " %F{#e0af68} ${VIRTUAL_ENV:t:h:t}%f" }
_char() { [[ $VI_MODE == cmd ]] && print -n '❮' || print -n '❯' }
export VIRTUAL_ENV_DISABLE_PROMPT=1

PROMPT='${_cmd_dur}$(_ssh_host)%(?.%F{#9ece6a}.%F{#f7768e})$(_char)%f '
RPROMPT='%F{#7aa2f7}%~%f${vcs_info_msg_0_}$(_venv)'
PROMPT2='%F{#565f89}▸▹%f '

# ── Colors & aliases ─────────────────────────────────────────
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lAh' la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..' ...='cd ../..'
alias g=git gs='git status -sb' gl='git log --oneline --graph -20' gd='git diff'
alias t='tmux new -A -s main'
command -v eza  >/dev/null && alias ls='eza --group-directories-first' ll='eza -la --git' lt='eza --tree -L 2'
command -v bat  >/dev/null && alias cat='bat -p'
command -v batcat >/dev/null && alias cat='batcat -p'   # debian names it batcat

# ── Your functions ───────────────────────────────────────────
vim()     { nvim "$@" }
pact()    { source .venv/bin/activate }
pdact()   { deactivate }
gg()      { git add "$1" && git commit -m "$2" }
acp()     { git add . && git commit -m "$1" && git push }
killport() {
  if command -v lsof >/dev/null; then lsof -ti :$1 | xargs -r kill
  else fuser -k $1/tcp; fi
}

# python project quickstart
pvim() {
  python3 -m venv .venv && source .venv/bin/activate
  pip install --upgrade pip
  pip install debugpy tqdm numpy basedpyright "$@"
  [[ -f main.py ]] || printf '\ndef main():\n    return\n\n\nif __name__ == "__main__":\n    main()\n' > main.py
  nvim main.py
}
# go project quickstart
gvim() {
  go mod init ${1:?module name}
  [[ -f main.go ]] || printf 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello, World!")\n}\n' > main.go
  nvim main.go
}
# rust project quickstart
rvim() { cargo init && nvim src/main.rs }

# tvim (TypeScript scaffold) lives in its own file to keep this one readable
[[ -f ~/.zsh/tvim.zsh ]] && source ~/.zsh/tvim.zsh

# ── Plugins (apt: zsh-autosuggestions zsh-syntax-highlighting) ──
for f in /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
         /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -f $f ]] && source $f && break
done
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
bindkey '^ ' autosuggest-accept

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"   # replaces omz `z`
command -v fzf >/dev/null && [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] \
  && source /usr/share/doc/fzf/examples/key-bindings.zsh
export FZF_DEFAULT_OPTS='--color=bg+:#292e42,fg:#c0caf5,hl:#7aa2f7,fg+:#c0caf5,hl+:#7dcfff,info:#e0af68,prompt:#9ece6a,pointer:#bb9af7,marker:#9ece6a,spinner:#bb9af7,header:#565f89 --border=rounded'

# syntax highlighting must be sourced last
for f in /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
         /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f $f ]] && source $f && break
done
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7dcfff'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7aa2f7'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7aa2f7'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'

# machine-local overrides (not in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
