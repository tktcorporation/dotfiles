#!/bin/bash
set -euo pipefail

echo "==> dotfiles setup"

# ── sudo keepalive ──────────────────────────────────────────────
# セットアップ中に何度もパスワードを求められるのを防ぐため、
# 最初に1回だけ認証しバックグラウンドでタイムスタンプを更新し続ける。
# sudo が存在しない環境や、sudoers に入っていない環境ではスキップする。
if command -v sudo &>/dev/null && sudo -v 2>/dev/null; then
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
fi

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

# ── 1Password pre-flight ────────────────────────────────────────
# .chezmoi.yaml.tmpl と dot_gitconfig.tmpl が 1Password に依存しているため、
# chezmoi が走る前にここで早期検出して、何が足りないかを具体的に伝える。
#
# 「黙って degrade」ではなく fail-fast にする方針。
# 過去に「op 未サインイン → signingkey が無音で空 → 数日後にコミット署名されてないと気付く」
# という事故があったため、最初に止めて気付かせる。

check_1password() {
    # ── Case 1: op バイナリ未インストール ──────────────────────
    if ! command -v op >/dev/null 2>&1; then
        cat >&2 <<'EOF'

==> ERROR: 1Password CLI (op) が見つかりません

このセットアップは Git コミット署名のために 1Password を必須にしています。

▶ 復旧手順:
  1. 1Password アプリをインストール (まだなら):
       https://1password.com/downloads/mac/
  2. 1Password CLI をインストール:
       brew install --cask 1password-cli
  3. 1Password アプリにサインイン後、
       Settings → Developer → "Integrate with 1Password CLI" を ON
  4. ターミナル再起動後、もう一度 setup.sh を実行

EOF
        exit 1
    fi

    # ── Case 2: op はあるが、サインイン済みアカウントなし ─────
    # `op account list` は サインイン済みアカウントが無いと空行を返す。
    # </dev/null で "Do you want to add an account manually now?" の対話に入るのを防ぐ。
    if ! op account list </dev/null 2>/dev/null | grep -q .; then
        cat >&2 <<'EOF'

==> ERROR: 1Password CLI が未サインインです

▶ 復旧手順:
  方法A (推奨): 1Password アプリ統合を有効化
       1. 1Password アプリ → Settings → Developer
       2. "Integrate with 1Password CLI" を ON
       3. ターミナル再起動

  方法B: コマンドラインで手動サインイン
       op account add
       op signin

  確認:
       op account list   # アカウントが表示されればOK

その後もう一度 setup.sh を実行してください。

EOF
        exit 1
    fi
}

check_1password

# ── chezmoi init & apply ────────────────────────────────────────
echo "==> Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation

