#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell Commands\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fzf() {
    exec "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"
    exec "~/.fzf/install"
}

main() {
    install_fzf
}

main
