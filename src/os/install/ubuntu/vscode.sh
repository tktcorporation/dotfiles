#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   VSCode\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dep \
    "https://update.code.visualstudio.com/latest/linux-deb-x64/insider" \
    "VSCode insider" \
    "code-insider"
