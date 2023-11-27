#!/bin/bash
set -eux
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Fisher\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fisher_plugins() {
    execute \
        "fish -c \"fisher install decors/fish-ghq\"" \
        "Install ghq"
    execute \
        "fish -c \"fisher install jethrokuan/fzf\"" \
        "Install fzf"
    execute \
        "fish -c \"fisher install jethrokuan/z\"" \
        "Install z"
}

main() {
    install_fisher_plugins
}

main
