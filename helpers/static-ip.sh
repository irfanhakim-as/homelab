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
# static-ip: Set static IP address.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help message
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -h, --help              Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# set static IP address
function set_static_ip() {
    PLATFORM="$(${SOURCE_DIR}/utils.sh --sysfetch -p)"
    # exit if platform is not linux
    if [ "${PLATFORM}" != "linux" ]; then
        echo "Platform ${PLATFORM} is not supported."
        exit 1
    else
        DISTRO="$(${SOURCE_DIR}/utils.sh --sysfetch -d)"
        FAMILY="$(${SOURCE_DIR}/utils.sh --sysfetch -f)"

        # get network config values from user
        required_variables=(
            "IPADDR="
            "GATEWAY="
            "DNS1=1.1.1.1"
            "DNS2=1.0.0.1"
        )

        # ubuntu
        if [ "${DISTRO}" == "ubuntu" ]; then
            required_variables+=(
                "NETWORK_INTERFACE=ens160"
            )
            # get values from user
            ${SOURCE_DIR}/utils.sh --input --get-user-input "${required_variables[@]}"
            ${SOURCE_DIR}/utils.sh --input --check-env "${required_variables[@]}"
            status="${?}"
            if [ "${status}" -ne 0 ]; then
                echo "ERROR: Values provided by user were not confirmed!"
                exit "${status}"
            fi
            # backup initial netplan config
            if [ ! -f "/etc/netplan/00-installer-config.yaml.bak" ]; then
                sudo cp -f "/etc/netplan/00-installer-config.yaml" "/etc/netplan/00-installer-config.yaml.bak"
            fi
            # copy netplan config template to /tmp
            cp -f "${SOURCE_DIR}/../templates/00-installer-config.yaml.tpl" "/tmp/00-installer-config.yaml.tpl"
            # interpret netplan config template
            ${SOURCE_DIR}/utils.sh --tpl --interpret "/tmp/00-installer-config.yaml.tpl" "values.txt"
            # copy netplan config to /etc/netplan
            sudo cp -f "/tmp/00-installer-config.yaml.tpl" "/etc/netplan/00-installer-config.yaml"
            # apply netplan config
            sudo netplan apply
        # debian
        elif [ "${DISTRO}" == "debian" ]; then
            required_variables+=(
                "NETWORK_INTERFACE=ens192"
                "NETMASK=255.255.255.0"
            )
            # get values from user
            ${SOURCE_DIR}/utils.sh --input --get-user-input "${required_variables[@]}"
            ${SOURCE_DIR}/utils.sh --input --check-env "${required_variables[@]}"
            status="${?}"
            if [ "${status}" -ne 0 ]; then
                echo "ERROR: Values provided by user were not confirmed!"
                exit "${status}"
            fi
            # backup initial interfaces config
            if [ ! -f "/etc/network/interfaces.bak" ]; then
                sudo cp -f "/etc/network/interfaces" "/etc/network/interfaces.bak"
            fi
            # copy interfaces config template to /tmp
            cp -f "${SOURCE_DIR}/../templates/interfaces.tpl" "/tmp/interfaces.tpl"
            # interpret interfaces config template
            ${SOURCE_DIR}/utils.sh --tpl --interpret "/tmp/interfaces.tpl" "values.txt"
            # copy interfaces config to /etc/netplan
            sudo cp -f "/tmp/interfaces.tpl" "/etc/network/interfaces"
            # restart networking service
            sudo systemctl restart networking.service
        # rhel
        elif [ "${FAMILY}" == "rhel" ]; then
            required_variables+=(
                "NETWORK_INTERFACE=ens192"
                "BOOTPROTO=none"
                "IPV6INIT=no"
                "IPV6_AUTOCONF=no"
                "ONBOOT=yes"
                "PREFIX=8"
            )
            # get values from user
            ${SOURCE_DIR}/utils.sh --input --get-user-input "${required_variables[@]}"
            ${SOURCE_DIR}/utils.sh --input --check-env "${required_variables[@]}"
            status="${?}"
            if [ "${status}" -ne 0 ]; then
                echo "ERROR: Values provided by user were not confirmed!"
                exit "${status}"
            fi
            NETWORK_INTERFACE="$(${SOURCE_DIR}/utils.sh --input --read-value-from_file "values.txt" "NETWORK_INTERFACE")"
            # backup initial ifcfg config
            if [ ! -f "/etc/sysconfig/network-scripts/ifcfg-${NETWORK_INTERFACE}.bak" ]; then
                sudo cp -f "/etc/sysconfig/network-scripts/ifcfg-${NETWORK_INTERFACE}" "/etc/sysconfig/network-scripts/ifcfg-${NETWORK_INTERFACE}.bak"
            fi
            # copy current ifcfg config to /tmp
            cp -f "/etc/sysconfig/network-scripts/ifcfg-${NETWORK_INTERFACE}" "/tmp/ifcfg-${NETWORK_INTERFACE}.tpl"
            # cp -f "${SOURCE_DIR}/../templates/ifcfg-${NETWORK_INTERFACE}.tpl" "/tmp/ifcfg-${NETWORK_INTERFACE}.tpl"
            # update ifcfg config template
            for v in "${required_variables[@]}"; do
                var="${v%=*}"
                value="$(${SOURCE_DIR}/utils.sh --input --read-value-from_file "values.txt" "${var}")"
                ${SOURCE_DIR}/utils.sh --input --update-value-in-file "${var}" "${value}" "/tmp/ifcfg-${NETWORK_INTERFACE}.tpl"
            done
            # copy ifcfg config to /etc/sysconfig/network-scripts
            sudo cp -f "/tmp/ifcfg-${NETWORK_INTERFACE}.tpl" "/etc/sysconfig/network-scripts/ifcfg-${NETWORK_INTERFACE}"
            # restart NetworkManager service
            sudo systemctl restart NetworkManager
        else
            echo "Distribution ${DISTRO} is not supported."
            exit 1
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

set_static_ip