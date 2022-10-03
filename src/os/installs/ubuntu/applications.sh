#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Dep Applications\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_table_plus() {

    if ! package_is_installed "tableplus"; then

        add_key "http://deb.tableplus.com/apt.tableplus.com.gpg.key" \
            || print_error "TablePlus (add key)"

        add_repo "deb [arch=amd64] https://deb.tableplus.com/debian tableplus main" \
            || print_error "TablePlus (add Repository)"

        update &> /dev/null \
            || print_error "TablePlus (resync package index files)"

    fi

    install_package "TablePlus" "tableplus"
}

install_postman() {
    execute \
        "snap install postman" \
        "Install postman" \
        || print_error "postman (snap install)"
}

install_jetbrains_toolbox() {
    execute \
        "curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash" \
        "Install jetbrains-toolbox" \
        || print_error "jetbrains-toolbox"
}

main() {
    install_dep \
        "https://release.gitkraken.com/linux/gitkraken-amd64.deb" \
        "GitKraken" \
        "gitkraken"

    install_package \
        "VS Code" \
        "code"

    install_package \
        "Discord dependencies" \
        "libgconf-2-4 libc++1"

    install_dep \
        "https://dl.discordapp.net/apps/linux/0.0.13/discord-0.0.13.deb" \
        "Discord" \
        "discord"

    install_dep \
        "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb" \
        "Slack" \
        "slack"

    install_table_plus

    install_postman

    install_jetbrains_toolbox
}

main
