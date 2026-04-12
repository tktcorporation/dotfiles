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
