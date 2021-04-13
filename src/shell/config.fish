#!/bin/bash

set -x GOPATH "$HOME"/go
set -x PATH "$PATH" "$GOPATH"/bin

# ----------
# bobthefish config
# ----------
set -g fish_prompt_pwd_dir_length 0  # ディレクトリ省略しない
set -g theme_newline_cursor yes  # プロンプトを改行した先に設ける
set -g theme_display_git_master_branch yes  # git の branch 名を表示
set -g theme_color_scheme dracula
set -g theme_display_date no  # 時刻を表示しないように設定
set -g theme_display_cmd_duration no  # コマンド実行時間の非表示

# ----------
# aliases
# ----------

# 現在の作業リポジトリをブラウザで表示する
alias ghr="gh repo view"

# リポジトリの一覧の中からブラウザで表示したい対象を検索・表示する
alias ghrl="gh repo view (ghq list | fzf | cut -d "/" -f 2,3)"

# リポジトリのディレクトリへ移動
alias gcd="cd (ghq root)/(ghq list | fzf)"

# push, commit していないリポジトリを列挙
git remind --path '/home/tktcorporation/src/github.com/tktcorporation/*' --path '/home/tktcorporation/src/github.com/tkt-actions/*' --path '/home/tktcorporation/src/github.com/lapras-inc/*' status

# aws cli
alias aws "docker run --rm -it -v ~/.aws:/root/.aws -v (pwd):/aws -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION amazon/aws-cli"


# ----------
# direnv
# ----------
set -x EDITOR code-insiders
eval (direnv hook fish)


# ----------
# bash aliases
# ----------
make -C "$HOME/.Bash2FishAliasesSync" sync _B2F_BASHRC="$HOME/.bash_aliases"; and source ~/.config/fish/b2f_aliases.fish
