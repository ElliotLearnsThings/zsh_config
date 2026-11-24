#!/usr/bin/env bash
# Dotfiles installer: zsh + tmux (Tokyo Night), cloned over SSH.
# Usage: bash install.sh            (run as the user you'll work as, inside Debian)
set -euo pipefail

BRANCH="${BRANCH:-termux-native}"
DOTS="${DOTS:-$HOME/.dotfiles}"
GH="git@github.com:ElliotLearnsThings"
TERMUX_HOME="/data/data/com.termux/files/home"

say() { printf '\033[38;2;122;162;247m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[38;2;224;175;104m!!\033[0m %s\n' "$*"; }

# ── packages ──────────────────────────────────────────────────
SUDO=""; [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null && SUDO="sudo"
if command -v apt-get >/dev/null; then
  say "Installing packages"
  $SUDO apt-get update -qq
  $SUDO apt-get install -y -qq git zsh tmux curl ripgrep fzf zoxide bat \
    zsh-autosuggestions zsh-syntax-highlighting lsof psmisc >/dev/null
  # eza is only in newer Debian; skip quietly if missing
  $SUDO apt-get install -y -qq eza >/dev/null 2>&1 || true
fi

# ── ssh check ─────────────────────────────────────────────────
say "Checking GitHub SSH access"
if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  warn "SSH to GitHub failed. Set up a key first: ssh-keygen -t ed25519 && cat ~/.ssh/id_ed25519.pub"
  exit 1
fi

# ── clone / update ────────────────────────────────────────────
mkdir -p "$DOTS"
for repo in zsh_config tmuxconf; do
  if [ -d "$DOTS/$repo/.git" ]; then
    say "Updating $repo"
    git -C "$DOTS/$repo" fetch -q origin "$BRANCH"
    git -C "$DOTS/$repo" checkout -q "$BRANCH"
    git -C "$DOTS/$repo" pull -q --ff-only origin "$BRANCH"
  else
    say "Cloning $repo ($BRANCH)"
    git clone -q -b "$BRANCH" "$GH/$repo.git" "$DOTS/$repo"
  fi
done

# ── link (backing up anything already there) ──────────────────
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP"; mv "$dst" "$BACKUP/"; warn "Backed up $dst -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  say "Linked $dst"
}
link "$DOTS/zsh_config/.zshrc"        "$HOME/.zshrc"
link "$DOTS/zsh_config/.zsh"          "$HOME/.zsh"
link "$DOTS/tmuxconf/.tmux.conf"      "$HOME/.tmux.conf"
mkdir -p "$HOME/.cache"

# ── termux colors (only if Termux's home is reachable) ────────
if [ -d "$TERMUX_HOME" ]; then
  mkdir -p "$TERMUX_HOME/.termux"
  cp "$DOTS/zsh_config/termux/colors.properties" "$TERMUX_HOME/.termux/colors.properties"
  say "Copied Termux colors (run 'termux-reload-settings' in Termux)"
fi

# ── nvm + node (linux build, not Termux's android one) ────────
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  say "Installing nvm + Node LTS"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash >/dev/null
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh" && nvm install --lts >/dev/null
fi

# ── default shell ─────────────────────────────────────────────
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  chsh -s "$(command -v zsh)" 2>/dev/null \
    && say "Default shell set to zsh" \
    || warn "chsh failed; in proot add 'exec zsh' to ~/.bashrc instead"
fi

say "Done. Start a new shell, or run: exec zsh"
