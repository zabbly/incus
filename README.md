# Incus builds

Incus package builds provided by Zabbly.

There are two repositories available:

* stable (latest release of Incus)
* daily (untested daily builds)

## Availability

Those packages are built for:

* Ubuntu 20.04 LTS (`focal`)
* Ubuntu 22.04 LTS (`jammy`)
* Debian 11 (`bullseye`) (`amd64` only)
* Debian 12 (`bookworm`)

## Installation

All commands should be run as root.

### Repository key

Packages provided by the repository are signed. In order to verify the integrity of the packages, you need to import the public key. First, verify that the fingerprint of [`key.asc`](https://pkgs.zabbly.com/key.asc) matches `4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD`:

```sh
curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint
```

```sh
pub   rsa3072 2023-08-23 [SC] [expires: 2025-08-22]
      4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD
uid                      Zabbly Kernel Builds <info@zabbly.com>
sub   rsa3072 2023-08-23 [E] [expires: 2025-08-22]
```

If so, save the key locally:

```sh
curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
```

### Stable repository

On any of the distributions above, you can add the package repository at `/etc/apt/sources.list.d/zabbly-incus-stable.sources`.

Run the following command to add the stable repository:

```sh
sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'
```

### Daily repository

On any of the distributions above, you can add the package repository at `/etc/apt/sources.list.d/zabbly-incus-daily.sources`.

Run the following command to add the daily repository:

```sh
sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-daily.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/daily
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'
```

### Installing Incus

Update your repository list with:

```sh
apt-get update
```

Then to install Incus, run:

```sh
apt-get install incus
```

## Repository

This repository gets actively rebased as new releases come out, DO NOT expect a linear git history.
