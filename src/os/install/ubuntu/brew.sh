#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"


main() {
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    print_in_purple "\n   Brew\n\n"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! package_is_installed "brew"; then

        execute \
            "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" \
            "Homebrew (install)" \
            || print_error "Homebrew (install)"

    fi
}

main