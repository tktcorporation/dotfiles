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

install_Bash2FishAliasesSync() {
    execute \
        "rm -rf $HOME/$bash_to_fish_file_name" \
        "Remove an old package (Bash2FishAliasesSync)" \
        || print_error "Bash2FishAliasesSync (remove an old package)"
    execute \
        "git clone  --quiet --depth 1 https://github.com/d0riven/Bash2FishAliasesSync.git $HOME/$bash_to_fish_file_name" \
        "Download Bash2FishAliasesSync" \
        || print_error "Bash2FishAliasesSync (git clone)"
}

install_fzf() {
    execute \
        "rm -rf $HOME/$fzf_file_name" \
        "Remove an old package (fzf)" \
        || print_error "fzf (remove an old package)"
    execute \
        "git clone  --quiet --depth 1 https://github.com/junegunn/fzf.git $HOME/$fzf_file_name" \
        "Download fzf" \
        || print_error "fzf (git clone)"
    execute \
        "$HOME/$fzf_file_name/install" \
        "Install fzf" \
        || print_error "fzf (install)"
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

main() {
    install_Bash2FishAliasesSync
    install_fzf
    install_ghq
    install_direnv
    install_git_remind
}

main
