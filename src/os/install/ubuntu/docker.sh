#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"


main() {
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    print_in_purple "\n   Docker\n\n"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! package_is_installed "docker-ce"; then

    add_key "https://download.docker.com/linux/ubuntu/gpg" \
        || print_error "Docker (add key)"

        add_repo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" \
        || print_error "Docker (add Repository)"

    update &> /dev/null \
        || print_error "Docker (resync package index files)"

    fi

    install_package "Docker" "docker-ce"

    add_usermod "docker"
}

main
