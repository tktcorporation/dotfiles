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
        "curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish"
}

install_fisher_plugin() {
    execute \
        "fisher install decors/fish-ghq \
        && fisher install jethrokuan/fzf \
        && fisher install jethrokuan/zz"
}

main() {

    print_in_purple "\n   Fish\n\n"

    install_fish
    install_fisher
    install_fisher_plugin
}

main
