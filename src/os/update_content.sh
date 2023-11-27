#!/bin/bash
set -eux

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    # gh command を使って ssh の設定を行う
    gh auth setup-git

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    print_in_purple "\n • Update content\n\n"

    ask_for_confirmation "Do you want to update the content from the 'dotfiles' directory?"

    if answer_is_yes; then

        git fetch --all 1> /dev/null \
            && git reset --hard origin/main 1> /dev/null \
            && git checkout main &> /dev/null \
            && git clean -fd 1> /dev/null

        print_result $? "Update content"

    fi

}

main
