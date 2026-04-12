#!/bin/bash
set -euo pipefail

echo "==> dotfiles setup"

# ── Xcode Command Line Tools ────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."

    # softwareupdate を使い GUI ダイアログなしでインストールする。
    # xcode-select --install は GUI 操作が必要なため、
    # curl | bash のようなヘッドレス実行では完了できない。
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    XCODE_PKG=$(softwareupdate -l 2>/dev/null \
        | grep -o 'Command Line Tools.*' \
        | head -n 1)

    if [ -z "$XCODE_PKG" ]; then
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        echo "ERROR: Xcode Command Line Tools package not found via softwareupdate." >&2
        echo "       Please install manually: xcode-select --install" >&2
        exit 1
    fi

    echo "    Installing: $XCODE_PKG"
    softwareupdate -i "$XCODE_PKG"
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    if xcode-select -p &>/dev/null; then
        echo "==> Xcode Command Line Tools installed."
    else
        echo "ERROR: Installation finished but xcode-select still not available." >&2
        echo "       Please install manually: xcode-select --install" >&2
        exit 1
    fi
else
    echo "==> Xcode Command Line Tools already installed."
fi

# ── chezmoi init & apply ────────────────────────────────────────
echo "==> Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation

