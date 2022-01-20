#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   GithubCLI\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_githubcli() {
    if ! package_is_installed "gh"; then
        execute \
            "sudo apt-key adv \
                --keyserver keyserver.ubuntu.com \
                --recv-key C99B11DEB97541F0" \
            &> /dev/null \
            || print_error "Github CLI (add key)"

        add_repo "https://cli.github.com/packages" \
            || print_error "Github CLI (add to package resource list)"

        update &> /dev/null \
            || print_error "Github CLI (resync package index files)"

    fi

    install_package "Github CLI" "gh"
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