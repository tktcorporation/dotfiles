#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   1Password\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    if ! package_is_installed "1password"; then

        execute \
            "sudo apt-key \
                --keyring /usr/share/keyrings/1password.gpg \
                adv --keyserver keyserver.ubuntu.com \
                --recv-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22" \
            || print_error "1Password (add key)"

        add_to_source_list \
            "[arch=amd64 signed-by=/usr/share/keyrings/1password.gpg] https://downloads.1password.com/linux/debian edge main \
                1password.list" \
            || print_error "1Password (add Repository)"

        update &> /dev/null \
            || print_error "1Password (resync package index files)"

    fi

    install_package "1Password" "1password"

}

main
