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
# hostname: Update hostname.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help message
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -h, --help              Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# set hostname
function set_hostname() {
    PLATFORM="$(${SOURCE_DIR}/utils.sh --sysfetch -p)"
    # exit if platform is not linux
    if [ "${PLATFORM}" != "linux" ]; then
        echo "Platform ${PLATFORM} is not supported."
        exit 1
    else
        # ensure hostnamectl is installed
        if ! [ -x "$(command -v hostnamectl)" ]; then
            echo "hostnamectl is not installed, please install it first."
            exit 1
        fi

        DISTRO="$(${SOURCE_DIR}/utils.sh --sysfetch -d)"
        FAMILY="$(${SOURCE_DIR}/utils.sh --sysfetch -f)"

        # get network config values from user
        required_variables=(
            "DOMAIN="
            "LOCAL_HOSTNAME="
        )

        # get values from user
        ${SOURCE_DIR}/utils.sh --input --get-user-input "${required_variables[@]}"
        ${SOURCE_DIR}/utils.sh --input --check-env "${required_variables[@]}"
        status="${?}"
        if [ "${status}" -ne 0 ]; then
            echo "ERROR: Values provided by user were not confirmed!"
            exit "${status}"
        fi

        # backup initial hosts config
        if [ ! -f "/etc/hosts.bak" ]; then
            sudo cp -f "/etc/hosts" "/etc/hosts.bak"
        fi

        # update hostname
        DOMAIN="$(${SOURCE_DIR}/utils.sh --input --read-value-from_file "values.txt" "DOMAIN")"
        LOCAL_HOSTNAME="$(${SOURCE_DIR}/utils.sh --input --read-value-from_file "values.txt" "LOCAL_HOSTNAME")"
        sudo hostnamectl set-hostname "${LOCAL_HOSTNAME}.${DOMAIN}"

        # ubuntu or debian
        if [ "${DISTRO}" == "ubuntu" ] || [ "${DISTRO}" == "debian" ]; then
            # copy hosts config template to /tmp
            cp -f "${SOURCE_DIR}/../templates/${DISTRO}-hosts.tpl" "/tmp/hosts.tpl"
            # interpret hosts config template
            ${SOURCE_DIR}/utils.sh --tpl --interpret "/tmp/hosts.tpl" "values.txt"
            # copy hosts config to /etc/hosts
            sudo cp -f "/tmp/hosts.tpl" "/etc/hosts"
        fi
    fi
}

# get arguments
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Invalid argument: ${1}"
            exit 1
            ;;
    esac
    shift
done

set_hostname