#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   kubectl\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    brew_install "kubectl" "kubernetes-cli/kubectl"
}

main