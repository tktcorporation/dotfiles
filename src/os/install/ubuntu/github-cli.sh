#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   GithubCLI\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_githubcli() {
    execute \
        "brew install gh" \
        "Install Github CLI(gh)" \
        || print_error "gh (brew install)"
}

install_extensions() {
    execute \
        "gh extension install mislav/gh-branch" \
        "gh-branch"
    
    execute \
        "gh extension install davidraviv/gh-clean-branches" \
        "gh-clean-branches"
}

main() {
    install_githubcli

    print_in_purple "\n   Extensions\n\n"
    install_extensions
}

main