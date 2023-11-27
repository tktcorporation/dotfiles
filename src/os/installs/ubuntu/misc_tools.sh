#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous Tools\n\n"

brew_install "cURL" "curl"
brew_install "ShellCheck" "shellcheck"
brew_install "xclip" "xclip"
brew_install "ClamAV" "clamav"
