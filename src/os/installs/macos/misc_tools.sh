#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous Tools\n\n"

brew_install "ShellCheck" "shellcheck"

if [ -d "$HOME/.nvm" ]; then
    brew_install "Yarn" "yarn"
fi

brew_install "GHQ" "ghq"
brew_install "FZF" "fzf"
brew_install "ClamAV" "clamav"
brew_install "Tldr" "tldr"
brew_install "jq" "jq"
brew_install "direnv" "direnv"
