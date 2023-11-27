#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   CopyQ\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! package_is_installed "copyq"; then

    add_ppa "hluk/copyq" \
        || print_error "CopyQ (add PPA)"

    update &> /dev/null \
        || print_error "CopyQ (resync package index files)"

fi

install_package "CopyQ" "copyq"
