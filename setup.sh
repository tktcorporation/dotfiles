#!/bin/bash
set -euo pipefail

echo "==> dotfiles setup"

# ── Xcode Command Line Tools ────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."

    # softwareupdate を使い GUI ダイアログなしでインストールする。
    # xcode-select --install は GUI 操作が必要なため、
    # curl | bash のようなヘッドレス実行では完了できない。
    # パターンは Homebrew の install.sh を参考にしている。
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    # softwareupdate の出力形式は macOS バージョンにより異なる:
    #   旧: "* Command Line Tools (macOS Mojave version 10.14) for Xcode-10.2"
    #   新: "* Label: Command Line Tools for Xcode-14.0"
    # sort -V | tail -n1 で最新安定版を選択（head -n1 だとベータを拾う場合がある）。
    CLT_LABEL=$(softwareupdate -l 2>/dev/null \
        | grep -B 1 -E 'Command Line Tools' \
        | awk -F'*' '/^ *\*/ {print $2}' \
        | sed -e 's/^ *Label: //' -e 's/^ *//' \
        | sort -V \
        | tail -n1)

    if [ -n "$CLT_LABEL" ]; then
        echo "    Installing: $CLT_LABEL"
        softwareupdate -i "$CLT_LABEL"
    else
        # softwareupdate でパッケージが見つからない場合、
        # TTY 環境なら xcode-select --install にフォールバックする。
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        if [ -t 0 ]; then
            echo "    softwareupdate にパッケージが見つかりません。GUI インストーラを起動します..."
            xcode-select --install
            echo "    GUI ダイアログに従ってインストールしてください。完了を待機中..."
            until xcode-select -p &>/dev/null; do
                sleep 5
            done
        else
            echo "ERROR: Xcode Command Line Tools package not found via softwareupdate." >&2
            echo "       Please install manually: xcode-select --install" >&2
            exit 1
        fi
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    # インストール先のパスを明示的に設定する
    if [ -d /Library/Developer/CommandLineTools ]; then
        sudo xcode-select --switch /Library/Developer/CommandLineTools
    fi

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

