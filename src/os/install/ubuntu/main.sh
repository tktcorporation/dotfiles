#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update
upgrade

./build-essentials.sh

./git.sh
# ./../nvm.sh
./langages.sh
./fish.sh
./shell-commands.sh
./fisher-plugins.sh
./docker.sh
./browsers.sh
./compression_tools.sh
# ./image_tools.sh
./misc.sh
./misc_tools.sh
# ./../npm.sh
./tmux.sh
./../vim.sh
./one-password.sh

./cleanup.sh
