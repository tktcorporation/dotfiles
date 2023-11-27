#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Terminal\n\n"

execute "gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 18'" \
    "Change font size"

# change font size in kde console
execute "gconftool-2 --type string --set /apps/konsole/profiles/Default/font 'Monospace 18'" \
    "Change font size"

execute "./set_terminal_theme.sh" \
    "Set custom terminal theme"
