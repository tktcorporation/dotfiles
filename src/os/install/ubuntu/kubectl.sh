#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   kubectl\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    execute "brew install kubectl"
}

main