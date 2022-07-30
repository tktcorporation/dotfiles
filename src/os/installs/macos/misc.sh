#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous\n\n"

brew_install "Android File Transfer" "android-file-transfer" "--cask"
# brew_install "eyeD3" "eye-d3"
# brew_install "Spectacle" "spectacle" "--cask"
# brew_install "Transmission" "transmission" "--cask"
# brew_install "Unarchiver" "the-unarchiver" "--cask"
# brew_install "VLC" "vlc" "--cask"
brew_install "MarkText" "mark-text" "--cask"
brew_install "Fig" "fig" "--cask"
brew_install "Alfred" "alfred" "--cask"
brew_install "Clipy" "clipy" "--cask"
brew_install "1Password" "1password" "--cask"
brew_install "GitKraken" "gitkraken" "--cask"
brew_install "Discord" "discord" "--cask"
brew_install "Slack" "slack" "--cask"
brew_install "Spark" "spark" "--cask"
