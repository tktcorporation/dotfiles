#!/bin/bash
set -eux
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
            "curl -sS https://downloads.1password.com/linux/keys/1password.asc \
                | sudo gpg --dearmor \
                | --output /usr/share/keyrings/1password-archive-keyring.gpg"
            "Add the key for the 1Password apt repository" \
            || print_error "1Password (add key)"

        add_to_source_list \
            "[arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] \
                https://downloads.1password.com/linux/debian/amd64 stable main" \
            "1password.list" \
            || print_error "1Password (add Repository)"
        
        execute \
            "sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ \
            && curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
                | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol \
            && sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 \
            && curl -sS https://downloads.1password.com/linux/keys/1password.asc \
                | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg"
            "Add the debsig-verify policy" \
            || print_error "1Password (debsig-verify policy)"

        update &> /dev/null \
            || print_error "1Password (resync package index files)"

    fi

    install_package "1Password" "1password"

}

main
