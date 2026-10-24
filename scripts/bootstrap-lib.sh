# setup.sh と run_onchange_before_install-packages.sh が共用する
# ブートストラップ関数群。sudo keepalive、Homebrew インストール、
# PATH 設定といった「セットアップ最初期の小道具」を SSOT で集約する。
#
# 読み込み方 (どちらも chezmoi の source dir にあるこのファイルを直接読む):
#
#   setup.sh 側 (stage 2。stage 1 でリポジトリを clone した後に exec される):
#     source "$CHEZMOI_SOURCE/scripts/bootstrap-lib.sh"
#
#   run_*.sh.tmpl 側:
#     source "{{ joinPath .chezmoi.sourceDir "scripts" "bootstrap-lib.sh" }}"
#
# 以前は setup.sh がこのファイルを main から別途 curl していたが、setup.sh と
# 別リビジョンになり得たため、clone 済みのものを読む形に統一した (setup.sh 冒頭参照)。
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
#
# 「インストール済み」の判定は 2 段階:
#   1. PATH 経由で `brew` コマンドが見える (普通の対話 shell)
#   2. 既知のインストールパスにバイナリが存在 (PATH 未設定の非対話 shell 向け)
#
# 2 を入れている理由: bash <(curl ...) 経由の非ログイン shell では PATH に
# /opt/homebrew/bin が入っていない場合があり、command -v brew だけだと
# 「既に入っているのに再インストール」してしまう (PR #89 Codex review)。
install_homebrew_if_missing() {
    if command -v brew >/dev/null 2>&1; then
        return
    fi
    if [ -x /opt/homebrew/bin/brew ] \
        || [ -x /usr/local/bin/brew ] \
        || [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        return
    fi
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
