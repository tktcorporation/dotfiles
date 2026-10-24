#!/bin/bash
set -euo pipefail

# dotfiles の初回セットアップ。`bash <(curl -fsLS .../setup.sh)` で実行する。
#
# 2 段階で動く:
#   stage 1 (curl で取得したこのファイル): Xcode CLT (git) を用意し、リポジトリを
#            chezmoi の source dir に clone (既にあれば fast-forward pull) して、
#            clone した側の setup.sh を exec する。
#   stage 2 (clone したリポジトリ内の setup.sh): 同じリポジトリの
#            scripts/bootstrap-lib.sh を読み込んで残りのセットアップを行う。
#
# なぜ 2 段階か: 以前は setup.sh と bootstrap-lib.sh を別々に main から curl していたため、
# 取得の間に main が進むと別リビジョン同士を組み合わせて実行する恐れがあった
# (関数の有無しか検査できず、実装の食い違いは検知できない)。stage 2 以降は
# clone した 1 つのコミットだけを実行するので、この組み合わせ問題が起きない。
# リモートから直接実行するのは stage 1 (このファイル) と Homebrew の公式 installer だけになる。

DOTFILES_REPO_URL="https://github.com/tktcorporation/dotfiles.git"
# XDG Base Directory Spec に従う: XDG_DATA_HOME が set なら $XDG_DATA_HOME/chezmoi。
# chezmoi 本体も同じ規約で source dir を解決するため、ここを揃えないと
# XDG_DATA_HOME を使っている環境で update が無効になる (Codex review PR #93)。
CHEZMOI_SOURCE="${XDG_DATA_HOME:-${HOME}/.local/share}/chezmoi"

# ── Xcode Command Line Tools ────────────────────────────────────
# git (リポジトリの clone に必要) を含むため、stage 1 の最初に用意する。
ensure_xcode_clt() {
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
}

if [ "${DOTFILES_SETUP_STAGE:-1}" = "1" ]; then
    echo "==> dotfiles setup"
    ensure_xcode_clt

    # ── 既存 chezmoi source の更新 ──────────────────────────────────
    # `chezmoi init <repo>` は ~/.local/share/chezmoi が既に存在する場合に
    # clone をスキップするが、pull は走らない。setup.sh を再実行した時に
    # 古い source を使い続ける罠 (例: writeToStderr バグ修正後も古い template
    # でコケ続ける) を避けるため、明示的に fast-forward pull する。
    # 未マージのローカル変更や divergent branch がある場合は --ff-only が
    # 失敗するので, 手元のカスタマイズを壊さない安全側に倒している。
    # .git はディレクトリとは限らない (source が git worktree だと .git はファイル) ため、
    # 存在チェックではなく git 自身にリポジトリかどうかを判定させる (Codex review)。
    if git -C "$CHEZMOI_SOURCE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "==> Updating existing chezmoi source ($CHEZMOI_SOURCE)..."
        if ! git -C "$CHEZMOI_SOURCE" pull --ff-only; then
            cat >&2 <<EOF

==> WARNING: chezmoi source の fast-forward pull に失敗しました
   $CHEZMOI_SOURCE にローカル変更や divergent commit がある可能性があります。
   このまま chezmoi init --apply を続けると古いテンプレで処理される恐れがあります。

   復旧手順 (どちらか):
     A) ローカル変更を整理してから setup.sh を再実行:
          cd "$CHEZMOI_SOURCE" && git status
     B) ローカル変更が不要なら source を作り直して setup.sh を再実行:
          rm -rf "$CHEZMOI_SOURCE"

EOF
            exit 1
        fi
    else
        echo "==> Cloning dotfiles into $CHEZMOI_SOURCE..."
        git clone "$DOTFILES_REPO_URL" "$CHEZMOI_SOURCE"
    fi

    DOTFILES_SETUP_STAGE=2 exec bash "$CHEZMOI_SOURCE/setup.sh" "$@"
fi

# ── stage 2: ここから下は clone したリポジトリのコミットで実行される ──
# shellcheck source=scripts/bootstrap-lib.sh
source "$CHEZMOI_SOURCE/scripts/bootstrap-lib.sh"

# ── sudo keepalive ──────────────────────────────────────────────
start_sudo_keepalive
trap 'kill "${SUDO_KEEPALIVE_PID:-}" 2>/dev/null || true' EXIT

# ── Touch ID for sudo ───────────────────────────────────────────
# brew cask は cask 毎に sudo を発行するため、Touch ID 無効だと
# install 中にパスワード入力が連発する (Brewfile に cask が 20+ ある現状は煩雑)。
# macOS Sonoma 以降は /etc/pam.d/sudo_local が OS update でも保持される
# 追加 PAM 設定として用意されており、pam_tid.so を有効化すれば
# sudo が Touch ID を受け付ける。
#
# 安全性:
#   - sufficient なので Touch ID 不在/失敗時は通常のパスワード認証に fallthrough
#   - Touch ID 未登録 / 非対応ハード (Mac mini 等) でも害なし
#   - sudo_local は OS update でリセットされる /etc/pam.d/sudo とは別ファイル
if [ -f /etc/pam.d/sudo_local.template ] && \
   ! sudo -n grep -q '^auth.*pam_tid\.so' /etc/pam.d/sudo_local 2>/dev/null; then
    echo "==> Enabling Touch ID for sudo (/etc/pam.d/sudo_local)..."
    # 既存ファイルがあれば中身を維持して append, なければ新規作成。
    # sudo_local は local customization 用のファイルなので、
    # ユーザーが他のルールを書いていた場合に破壊しないこと (Codex review PR #96)。
    if sudo -n test -e /etc/pam.d/sudo_local; then
        sudo tee -a /etc/pam.d/sudo_local >/dev/null <<'EOF'

# Touch ID for sudo (added by tktcorporation/dotfiles setup.sh)
auth       sufficient     pam_tid.so
EOF
    else
        sudo tee /etc/pam.d/sudo_local >/dev/null <<'EOF'
# Managed by tktcorporation/dotfiles setup.sh
# Touch ID を sudo で使えるようにする。失敗時はパスワード認証にフォールスルー。
auth       sufficient     pam_tid.so
EOF
    fi
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

install_homebrew_if_missing
load_brew_shellenv

# chezmoi も Homebrew から入れる。以前は get.chezmoi.io のインストーラを
# curl | sh していたが、Homebrew を既に信頼している以上、取得元を増やす理由がない。
# (Brewfile にも chezmoi があるので後段の brew bundle では no-op になる)
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "==> Installing chezmoi..."
    brew install chezmoi
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
# `op whoami` は **認証必須** のコマンドなので、サインアウト中や
# セッション失効中なら exit 非ゼロで失敗する。`op account list` は
# 「アカウント設定の有無」しか確認しないため、サインアウト中でも通って
# しまう (PR #89 Codex review で指摘) ため使わない。
# </dev/null は op が対話プロンプトに入るのを防ぐためのガード。
if ! op whoami </dev/null >/dev/null 2>&1; then
    cat >&2 <<'EOF'

==> 1Password にサインインしてください

1Password アプリと CLI は準備できました。最後のひと手間として、
サインインが必要です。chezmoi はここから SSH 署名キーを取得します。

▶ やること:
  1. 1Password アプリを起動してサインイン
  2. アプリ内 Settings → Developer → "Integrate with 1Password CLI" を ON
  3. ターミナルを開き直す (shellenv 再読込のため)
  4. 確認:
       op whoami         # アカウント情報が表示されればOK (アクティブなセッションが必要)
  5. もう一度 setup.sh を実行

補足: GUI を使わず CLI だけでサインインしたい場合は:
       op account add
       op signin

EOF
    exit 1
fi

# ── chezmoi init & apply ────────────────────────────────────────
# source dir は stage 1 で用意済みなので、リポジトリ指定なしで init する
# (既存 source を使い、設定ファイル生成と apply だけを行う)。
echo "==> Applying dotfiles..."
chezmoi init --apply
