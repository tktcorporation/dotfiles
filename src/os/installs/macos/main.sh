#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

./xcode.sh
./homebrew.sh
./bash.sh

./git.sh
./docker.sh
./browsers.sh
./misc.sh
./misc_tools.sh
./quick_look.sh
./video_tools.sh
./vscode.sh
./web_font_tools.sh
