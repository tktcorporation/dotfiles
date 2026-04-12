#!/bin/bash
set -euo pipefail

echo "==> dotfiles setup"

# ── Xcode Command Line Tools ────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install

    echo "    Waiting for installation to complete (follow the GUI dialog)..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    echo "==> Xcode Command Line Tools installed."
else
    echo "==> Xcode Command Line Tools already installed."
fi

# ── chezmoi init & apply ────────────────────────────────────────
echo "==> Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation

# ── ziku init (dev environment templates) ───────────────────────
# Homebrew and mise are now installed by chezmoi; activate them for this session
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v mise &>/dev/null; then
    eval "$(mise activate bash --shims)"
fi

if command -v npx &>/dev/null; then
    echo "==> Running ziku init..."
    npx -y ziku init
else
    echo "==> Skipping ziku init (npx not found)"
fi
