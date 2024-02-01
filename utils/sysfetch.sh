#!/bin/bash
#
#         :::   :::  ::::::::::::::    :::    :::
#       :+:+: :+:+:     :+:    :+:   :+:   :+: :+:
#     +:+ +:+:+ +:+    +:+    +:+  +:+   +:+   +:+  Irfan Hakim (MIKA)
#    +#+  +:+  +#+    +#+    +#++:++   +#++:++#++:  https://sakurajima.social/@irfan
#   +#+       +#+    +#+    +#+  +#+  +#+     +#+   https://github.com/irfanhakim-as
#  #+#       #+#    #+#    #+#   #+# #+#     #+#
# ###       #################    ######     ###
#
# sysfetch: Fetch system configuration.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -a, --arch              Identify architecture."
    echo "  -d, --distro            Identify distribution."
    echo "  -f, --family            Identify distribution family."
    echo "  -k, --kernel            Identify kernel release."
    echo "  -m, --mode              Identify mode (gui or cli)."
    echo "  -p, --platform          Identify platform."
    echo "      --all               List all system configuration."
    echo "  -h, --help              Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# identify platform
function identify_platform() {
    if [ "$(uname)" == "Darwin" ]; then
        PLATFORM="macos"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        PLATFORM="linux"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        PLATFORM="windows"
    else
        PLATFORM="unknown"
    fi
    echo "${PLATFORM}"
}

# identify distro family
function identify_family() {
    FAMILY="unknown"
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        # arch
        if [[ "${ID}" == *"arch"* ]] || [[ "${ID_LIKE}" == *"arch"* ]]; then
            FAMILY="arch"
        # debian
        elif [[ "${ID}" == *"debian"* ]] || [[ "${ID_LIKE}" == *"debian"* ]]; then
            FAMILY="debian"
        # rhel
        elif [[ "${ID}" == *"rhel"* ]] || [[ "${ID_LIKE}" == *"rhel"* ]]; then
            FAMILY="rhel"
        fi
    fi
    echo "${FAMILY}"
}

# identify distro
function identify_distro() {
    DISTRO="unknown"
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        # arch
        if [[ "${ID}" == *"arch"* ]]; then
            DISTRO="arch"
        # debian
        elif [[ "${ID}" == *"debian"* ]]; then
            DISTRO="debian"
        # rhel
        elif [[ "${ID}" == *"rhel"* ]]; then
            DISTRO="rhel"
        # others
        else
            # lowercase ID
            DISTRO="$(echo "${ID}" | awk '{print tolower($0)}')"
        fi
    fi
    echo "${DISTRO}"
}

# identify architecture
function identify_arch() {
    ARCH="$(uname -m)"
    echo "${ARCH}"
}

# identify kernel
function identify_kernel() {
    KERNEL_RELEASE="$(uname -r)"
    # if wsl
    if [[ "${KERNEL_RELEASE}" == *"microsoft-standard-WSL"* ]]; then
        KERNEL_RELEASE="wsl"
    fi
    echo "${KERNEL_RELEASE}"
}

# identify mode (gui or cli)
function identify_mode() {
    MODE="headless"
    if [ -n "${DISPLAY}" ]; then
        # check for desktop environment
        if [ -n "${XDG_CURRENT_DESKTOP}" ]; then
            MODE="gui"
        fi
    fi
    echo "${MODE}"
}

# get arguments
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -a|--arch)
            identify_arch
            ;;
        -d|--distro)
            identify_distro
            ;;
        -f|--family)
            identify_family
            ;;
        -k|--kernel)
            identify_kernel
            ;;
        -m|--mode)
            identify_mode
            ;;
        -p|--platform)
            identify_platform
            ;;
        --all)
            identify_platform
            identify_family
            identify_distro
            identify_arch
            identify_kernel
            identify_mode
            ;;
        -h|--help)
            print_help
            ;;
        *)
            echo "Invalid argument: ${1}"
            exit 1
            ;;
    esac
    shift
done