#!/bin/bash

import_key() {
    # Verify the public key fingerprint
    fingerprint="4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD"
    fingerprint_verified=false

    # echo "Please verify the fingerprint of the key.asc:"
    fingerprint_output=$(curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint)

    if [[ $fingerprint_output == *"$fingerprint"* ]]; then
        fingerprint_verified=true
    fi

    if $fingerprint_verified; then
        # Save the public key locally
        mkdir -p /etc/apt/keyrings/
        curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc

        echo "Key saved locally."
    else
        echo "Fingerprint does not match. Aborting..."
        exit 1
    fi
}

add_repository() {
    repository_type=$1

    if [[ $repository_type == "stable" ]]; then
        # Add the Stable version repository
        cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF
        echo "Stable repository added."
    elif [[ $repository_type == "daily" ]]; then
        # Add the Daily version repository
        cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-daily.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/daily
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF
        echo "Daily repository added."
    else
        echo "Invalid repository type. Aborting..."
        exit 1
    fi
}

install_incus() {
    # Update the software source list
    apt-get update

    # Install Incus
    apt-get install -y incus

    echo "Incus installed."
}

uninstall_incus() {
    # Uninstall Incus
    apt-get remove -y incus

    echo "Incus uninstalled."
}

echo -e "Which operation do you want to do ?\n1: Install Stable\n2: Install Daily\n3: Uninstall\nPlease enter the number 1, 2, or 3 and press Enter to confirm your selection: "

read operation

if [[ $operation == "1" ]]; then
    import_key
    add_repository "stable"
    install_incus
elif [[ $operation == "2" ]]; then
    import_key
    add_repository "daily"
    install_incus
elif [[ $operation == "3" ]]; then
    uninstall_incus
else
    echo "Invalid operation. Aborting..."
    exit 1
fi

exit 0
