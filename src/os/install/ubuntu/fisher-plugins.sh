#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Fisher\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fisher_plugins() {
    execute \
        "fish -c \"fisher install decors/fish-ghq \
        && fisher install jethrokuan/fzf \
        && fisher install jethrokuan/zz\""
}

main() {
    install_fisher_plugins
}

main
