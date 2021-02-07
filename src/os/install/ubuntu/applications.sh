#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Dep Applications\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dep \
    "https://release.gitkraken.com/linux/gitkraken-amd64.deb" \
    "GitKraken" \
    "gitkraken"

install_dep \
    "https://update.code.visualstudio.com/latest/linux-deb-x64/insider" \
    "VSCodeInsider" \
    "code-insider"

install_dep \
    "https://dl.discordapp.net/apps/linux/0.0.13/discord-0.0.13.deb" \
    "Discord" \
    "discord"

install_dep \
    "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb" \
    "Slack" \
    "slack"

