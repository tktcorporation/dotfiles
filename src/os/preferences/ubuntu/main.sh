#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

./privacy.sh
./terminal.sh
./ui_and_ux.sh
./shell.sh
