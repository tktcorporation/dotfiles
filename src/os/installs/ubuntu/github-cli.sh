#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   GithubCLI\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_githubcli() {
    brew_install "GithubCLI" "github/gh/gh"
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