#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Langages\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! package_is_installed "golang-go"; then

    add_ppa "longsleep/golang-backports" \
        || print_error "Go (add PPA)"

    update &> /dev/null \
        || print_error "Go (resync package index files)"

fi

install_package "Go" "golang-go"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
