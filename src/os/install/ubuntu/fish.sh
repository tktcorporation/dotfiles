#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fish() {
    if ! package_is_installed "fish"; then

        print_error "Fish (package is not installed)"

    fi

    install_package "Fish" "fish"
}

install_fisher() {
    execute \
        "curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish" \
        "Fish"
}

main() {

    print_in_purple "\n   Fish\n\n"

    install_fish
    install_fisher
}

main
