#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   kubectl\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_kubectl() {
    if ! package_is_installed "kubectl"; then
        execute \
            "sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl" \
            &> /dev/null \
            || print_error "kubectl (install packages needed to use)"

        execute \
            "sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
                https://packages.cloud.google.com/apt/doc/apt-key.gpg" \
            &> /dev/null \
            || print_error "kubectl (Download the Google Cloud public signing key)"

        execute "echo \"deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
            https://apt.kubernetes.io/ kubernetes-xenial main\" | \
            sudo tee /etc/apt/sources.list.d/kubernetes.list" \
            || print_error "kubectl (Add the Kubernetes apt repository)"

        update &> /dev/null \
            || print_error "kubectl (resync package index files)"

    fi

    install_package "kubectl" "kubectl"
}

main() {
    install_kubectl
}

main