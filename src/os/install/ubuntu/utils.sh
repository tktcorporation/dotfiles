#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

w_get() {
    declare -r URL="$2"
    declare -r PACKAGE_NAME="$1"

    wget -qO "$PACKAGE_NAME" "$URL" &> /dev/null
}

add_key() {

    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

}

add_ppa() {
    sudo add-apt-repository -y ppa:"$1" &> /dev/null
}

add_repo() {
    sudo add-apt-repository "$1" &> /dev/null
}

add_to_source_list() {
    sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'"
}

autoremove() {

    # Remove packages that were automatically installed to satisfy
    # dependencies for other packages and are no longer needed.

    execute \
        "sudo apt autoremove -qqy" \
        "APT (autoremove)"

}

install_package() {

    declare -r EXTRA_ARGUMENTS="$3"
    declare -r PACKAGE="$2"
    declare -r PACKAGE_READABLE_NAME="$1"

    if ! package_is_installed "$PACKAGE"; then
        execute "sudo apt install --allow-unauthenticated -qqy $EXTRA_ARGUMENTS $PACKAGE" "$PACKAGE_READABLE_NAME"
        #                                  suppress output ─┘│
        #        assume "yes" as the answer to all prompts ──┘
    else
        print_success "$PACKAGE_READABLE_NAME"
    fi

}

install_dep_package() {

    declare -r EXTRA_ARGUMENTS="$3"
    declare -r PACKAGE="$2"
    declare -r PACKAGE_READABLE_NAME="$1"

    if ! package_is_installed "$PACKAGE"; then
        execute \
            "sudo apt install -qy $EXTRA_ARGUMENTS $PACKAGE" \
            "$PACKAGE_READABLE_NAME"
    else
        print_success "$PACKAGE_READABLE_NAME"
    fi

}

install_dep() {
    declare -r EXTRA_ARGUMENTS="$4"
    declare -r PACKAGE="${3}.dep"
    declare -r PACKAGE_READABLE_NAME="$2"
    declare -r DEP_URL="$1"

    w_get "$PACKAGE" "$DEP_URL" \
        || print_error "install_$PACKAGE (wget)"

    install_dep_package "$PACKAGE_READABLE_NAME" "./$PACKAGE" "$EXTRA_ARGUMENTS"
}

package_is_installed() {
    dpkg -s "$1" &> /dev/null
}

update() {

    # Resynchronize the package index files from their sources.

    execute \
        "sudo apt update -qqy" \
        "APT (update)"

}

upgrade() {

    # Install the newest versions of all packages installed.

    execute \
        "export DEBIAN_FRONTEND=\"noninteractive\" \
            && sudo apt -o Dpkg::Options::=\"--force-confnew\" upgrade -qqy" \
        "APT (upgrade)"

}

add_usermod() {
    execute \
        "sudo usermod -aG $1 ${USER}" \
        "Add ${USER} to $1 (usermod)"
}
