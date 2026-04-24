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

# ── 1Password bootstrap ─────────────────────────────────────────
# .chezmoi.yaml.tmpl と dot_gitconfig.tmpl が 1Password に依存しているため、
# chezmoi が走る前にここで最小限の bootstrap を済ませる:
#   1. Homebrew を用意 (なければインストール)
#   2. 1Password アプリ (GUI) が無ければ cask で入れる (既存インストールは尊重)
#   3. 1Password CLI (op) が無ければ cask で入れる
#   4. サインイン状態をチェック。未サインインなら復旧手順を出して exit 1
#
# 残りの Brewfile 全体は chezmoi apply 中に run_onchange_before_install-packages.sh
# が適用する。ここで入れる 2 つは後段で no-op になるだけ (idempotent)。
#
# 「op が未準備なら無音 degrade」から「fail-fast with guidance」への方針転換。

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew を現在セッションの PATH に通す (Apple Silicon / Intel 両対応)
# Homebrew インストール直後は PATH に入っていないため明示的に設定する。
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 1Password アプリ (GUI): 既存の /Applications/1Password.app を尊重。
# Mac App Store や公式 DMG で入れた場合と衝突しないよう、ディレクトリの
# 有無で判定してから cask インストールする。
if [ ! -d /Applications/1Password.app ]; then
    echo "==> Installing 1Password (app)..."
    brew install --cask 1password
fi

# 1Password CLI (op)
if ! command -v op >/dev/null 2>&1; then
    echo "==> Installing 1Password CLI..."
    brew install --cask 1password-cli
fi

# ── 1Password サインイン状態チェック (ユーザー操作必須) ────────
# op バイナリまでは自動で揃えられるが、サインインはユーザーにしか
# できない。未サインインなら明確な手順を示して止める。
#
# `op account list` は 未サインインだと空出力で exit 0 を返すため
# `grep -q .` で「1行でも出るか」を判定する。`</dev/null` は op が
# 対話プロンプト (Do you want to add an account manually now?) に
# 入るのを防ぐためのガード。
if ! op account list </dev/null 2>/dev/null | grep -q .; then
    cat >&2 <<'EOF'

==> 1Password にサインインしてください

1Password アプリと CLI は準備できました。最後のひと手間として、
サインインが必要です。chezmoi はここから SSH 署名キーを取得します。

▶ やること:
  1. 1Password アプリを起動してサインイン
  2. アプリ内 Settings → Developer → "Integrate with 1Password CLI" を ON
  3. ターミナルを開き直す (shellenv 再読込のため)
  4. 確認:
       op account list   # アカウントが表示されればOK
  5. もう一度 setup.sh を実行

補足: GUI を使わず CLI だけでサインインしたい場合は:
       op account add
       op signin

EOF
    exit 1
fi

# ── chezmoi init & apply ────────────────────────────────────────
echo "==> Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation

