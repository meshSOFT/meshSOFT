#!/usr/bin/env bash
# MESHSOFT INSTALLATION SCRIPT
# curl -fsSL https://bit.ly/get-meshsoft | bash
# wget -qO- https://bit.ly/get-meshsoft | bash

set -euo pipefail

# Require sudo privileges
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "This script needs sudo privilege to install system packages and services."
    if id -nG "$USER" | grep -qw sudo; then      
        echo "Please enter your password:"
        if [ -t 0 ]; then
            exec sudo bash "$0" "$@"
        else
            exec sudo bash -s -- "$@"
        fi
    else
        echo "Please enter your root password:"
        if [ -t 0 ]; then
            exec su -c "bash '$0' $*"
        else
            exec su -c "bash -s -- $@" </dev/tty
        fi
    fi
fi

echo "#################################################################################"
echo "1. READ HARDWARE INFO:"
OS=$(uname -s)
OS_VERSION=$(lsb_release -sd 2>/dev/null)
ARCH=$(uname -m)
CPU=$(lscpu | grep 'CPU\|Thread\|Core\|Socket\|Vendor ID\|Model name')
echo "$OS: $OS_VERSION $ARCH"
echo "$CPU"

echo ""
echo "#################################################################################"
echo "2. INSTALL SYSTEM PACKAGE:"
apt update -qq && apt purge netcat-traditional -qq -y && apt install ca-certificates curl wget netcat-openbsd p7zip-full avahi-daemon -qq -y

echo ""
echo "#################################################################################"
echo "3. INSTALL DOCKER:"
if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    echo "Installing Docker ...."
    curl -fsSL https://get.docker.com | sh
fi

if command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose is already installed."
else
    echo "Installing Docker Compose ...."
    case "$ARCH" in
        x86_64)
            curl -u "s7iTdaw9Z3Rdtt7:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/amd64/docker-compose-1.29.2" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            ;;
        aarch64)
            curl -u "s7iTdaw9Z3Rdtt7:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/arm64/docker-compose-1.29.2" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            ;;
        *)
            echo "Unsupported architecture: $ARCH" >&2
            exit 1
            ;;
    esac
fi

echo "$(docker -v)"
echo "$(docker-compose -v)"

echo ""
echo "#################################################################################"
echo "4. INSTALL MESHSOFT:"
echo "4.1. Create file directory ..."
mkdir -p /opt/shared/meshsoft_app
mkdir -p /opt/shared/meshsoft_installer/download_version
mkdir -p /opt/shared/meshsoft_installer/latest_version
mkdir -p /opt/shared/meshsoft_installer/previous_version
mkdir -p /opt/shared/meshsoft_userdata/fs

echo "4.2. Download meshSOFT ..."
MESHSOFT_INSTALLER_PATH="/opt/shared/meshsoft_installer/latest_version"
MESHSOFT_VERSION_CODE="jJ4zzzFkMbFg6s9"
case "$ARCH" in
    x86_64)
        echo "x86_64"
        curl -u "$MESHSOFT_VERSION_CODE:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/amd64/ReleaseNotes.txt" -o $MESHSOFT_INSTALLER_PATH/ReleaseNotes.txt
        curl -u "$MESHSOFT_VERSION_CODE:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/amd64/meshsoft_installer.zip" -o $MESHSOFT_INSTALLER_PATH/meshsoft_installer.zip
        ;;
    aarch64)
        echo "aarch64"
        curl -u "$MESHSOFT_VERSION_CODE:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/arm64/ReleaseNotes.txt" -o $MESHSOFT_INSTALLER_PATH/ReleaseNotes.txt
        curl -u "$MESHSOFT_VERSION_CODE:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/arm64/meshsoft_installer.zip" -o $MESHSOFT_INSTALLER_PATH/meshsoft_installer.zip
        ;;
    *)
        echo "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

echo "4.3. Install meshSOFT ..."
cd $MESHSOFT_INSTALLER_PATH && rm -rf meshsoft_installer
cd $MESHSOFT_INSTALLER_PATH && 7z x -p"m3shlinkPack3d!" meshsoft_installer.zip
curl -u "Qii3FNbtzWEdMbz:any" -H "X-Requested-With: XMLHttpRequest" "https://share.mesh-tech.de/public.php/webdav/meshsoft_updater_fresh_install.sh" -o ./meshsoft_updater_fresh_install.sh
chmod +x ./meshsoft_updater_fresh_install.sh && source ./meshsoft_updater_fresh_install.sh
cd $MESHSOFT_INSTALLER_PATH && rm -rf meshsoft_installer

echo ""
echo "#################################################################################"
echo "DONE. To get started, go to: http://$HOSTNAME.local:9000"

