# setup.sh と run_onchange_before_install-packages.sh が共用する
# ブートストラップ関数群。sudo keepalive、Homebrew インストール、
# PATH 設定といった「セットアップ最初期の小道具」を SSOT で集約する。
#
# 読み込み方:
#
#   setup.sh 側 (curl|bash でリポジトリが未クローンの段階):
#     LIB_URL="https://raw.githubusercontent.com/tktcorporation/dotfiles/main/scripts/bootstrap-lib.sh"
#     LIB_TMP=$(mktemp)
#     curl -fsSL "$LIB_URL" -o "$LIB_TMP"
#     # shellcheck source=/dev/null
#     source "$LIB_TMP" && rm -f "$LIB_TMP"
#
#   run_onchange_*.sh.tmpl 側 (chezmoi sourceDir が既にある):
#     source "{{ joinPath .chezmoi.sourceDir "scripts" "bootstrap-lib.sh" }}"
#
# 注意: このファイル自体はシェルスクリプトとして `bash -n` で構文検査可能だが
# 単体で実行するものではない。関数定義しか含まないので source されて使われる。

# sudo を事前認証してバックグラウンドで維持する。
# セットアップ中に複数の sudo コマンドが走ってもパスワード入力を
# 求められないようにする (ヘッドレス実行でも通るようにするため)。
#
# グローバル変数 $SUDO_KEEPALIVE_PID に PID を設定するので、呼び出し側は
# 次のように trap でクリーンアップすること:
#   trap 'kill "${SUDO_KEEPALIVE_PID:-}" 2>/dev/null || true' EXIT
#
# sudo が無い or sudoers に入っていない (Linuxbrew 非 root、CI コンテナ等)
# の環境では何もせずに返る。
start_sudo_keepalive() {
    SUDO_KEEPALIVE_PID=""
    if command -v sudo >/dev/null 2>&1 && sudo -v 2>/dev/null; then
        while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
        SUDO_KEEPALIVE_PID=$!
    fi
}

# Homebrew が未インストールなら公式 installer を実行する。
# 既にインストール済みなら何もしない (idempotent)。
install_homebrew_if_missing() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# brew を現在シェルセッションの PATH に通す。
# Homebrew インストール直後や、shellenv を evaluate していない環境で必要。
# Apple Silicon Mac / Intel Mac / Linuxbrew の 3 配置に対応する。
load_brew_shellenv() {
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}
