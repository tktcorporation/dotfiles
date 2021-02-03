#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell Commands\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fzf() {
    execute \
        "rm -rf $HOME/.fzf" \
        "Remove an old package (fzf)"
        || print_error "fzf (remove an old package)"
    execute \
        "git clone  --quiet --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf" \
        "Download fzf" \
        || print_error "fzf (git clone)"
    execute \
        "$HOME/.fzf/install" \
        "Install fzf" \
        || print_error "fzf (install)"
}

main() {
    install_fzf
}

main
