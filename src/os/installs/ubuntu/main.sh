#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update
upgrade

./build-essentials.sh

./brew.sh
./github-cli.sh
./git.sh
./langages.sh
# ./fish.sh
./shell-commands.sh
./fisher-plugins.sh
./docker.sh
./browsers.sh
./misc.sh
./misc_tools.sh
./one-password.sh
./kubectl.sh
./copyq.sh
./applications.sh
./ime.sh

./cleanup.sh
