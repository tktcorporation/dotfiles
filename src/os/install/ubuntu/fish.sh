#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fish() {
    brew_install "Fish" "fish"
}

install_fisher() {
    brew_install "Fisher" "fisher"
}

install_zsh() {
    brew_install "Zsh" "zsh"
}

main() {
    install_zsh

    print_in_purple "\n   Fish\n\n"

    install_fish
    install_fisher
}

main
