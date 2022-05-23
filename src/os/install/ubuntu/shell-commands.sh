#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell Commands\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare bash_to_fish_file_name=".Bash2FishAliasesSync"
declare fzf_file_name=".fzf"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fzf() {
    brew_install "FZF" "fzf"
}

install_ghq() {
    execute \
        "go get -u github.com/x-motemen/ghq" \
        "Install ghq" \
        || print_error "ghq (go get)"
}

install_direnv() {
    execute \
        "go get -u github.com/direnv/direnv" \
        "Install direnv" \
        || print_error "direnv (go get)"
}

install_git_remind() {
    execute \
        "go get -u github.com/suin/git-remind" \
        "Install git-remind" \
        || print_error "git-remind (go get)"
}

install_zoxide() {
    execute \
        "cargo install zoxide" \
        "Install zoxide" \
        || print_error "zoxide (cargo install)"
}

install_bat() {
    execute \
        "cargo install bat" \
        "Install bat" \
        || print_error "bat (cargo install)"
}

install_ripgrep() {
    execute \
        "cargo install ripgrep" \
        "Install ripgrep" \
        || print_error "ripgrep (cargo install)"
}

install_jq() {
    brew_install "jq" "jq"
}

install_tldr() {
    brew_install "Tldr" "tldr"
}

main() {
    install_Bash2FishAliasesSync
    install_fzf
    install_ghq
    install_direnv
    install_git_remind
    install_zoxide
    install_bat
    install_ripgrep
    install_jq
    install_tldr
}

main
