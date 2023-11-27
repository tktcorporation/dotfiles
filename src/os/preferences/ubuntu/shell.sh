#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell\n\n"

execute "sudo chsh $USER -s $(which fish)" \
    "Change default shell to fish"

