#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   GitKraken\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gitkraken() {
    w_get "https://release.gitkraken.com/linux/gitkraken-amd64.deb" \
        || print_error "gitkraken (wget)"
    execute \
        "sudo dpkg -i gitkraken-amd64.deb" \
        "Install GitKraken"
}

main() {
    install_gitkraken
}

main
