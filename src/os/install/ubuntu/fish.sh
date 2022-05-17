#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fish() {
    execute "brew install fish"
}

install_fisher() {
    execute "brew install fisher"
}

install_zsh() {
    execute "brew install zsh"
}

main() {

    print_in_purple "\n   Fish\n\n"

    install_fish
    install_fisher

    install_zsh
}

main
