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
# input: Utility pertaining user input and values.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help message
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -c, --check-env                    Get confirmation on environment variables from value file."
    echo "  -g, --get-user-input               Get value through user input and output a value file."
    echo "  -r, --read-value-from_file         Get variable value from a value file."
    echo "  -u, --update-value-in-file         Update or add variable to a file from a value file."
    echo "  -h, --help                         Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# check if all environment variables are set correctly
function check_env() {
    # check if all variables are set
    for v in "${@}"; do
        var="${v%=*}"
        # if [ -z "${!var}" ]; then
        if [ -z "$(read_value_from_file "values.txt" "${var}")" ]; then
            echo "ERROR: ${var} has not been set"
            return 1
        else
            # echo "${var} = \"${!var}\""
            echo "${var} = \""$(read_value_from_file "values.txt" "${var}")"\""
        fi
    done
    # check if user would like to continue with all values
    read -p "Would you like to continue with the above values? [y/N]: " -n 1 -r; echo
    if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
        return 1
    else
        return 0
    fi
}

# read a variable value from a file
function read_value_from_file() {
    file="${1}"
    var="${2}"
    if [ -f "${file}" ]; then
        # if variable is found in file, get the value
        if grep -q "${var}" "${file}"; then
            l=$(grep "${var}" "${file}")
            existing_value="${l#*=}"
            echo "${existing_value}"
        fi
    fi
}

# update a variable value in a file
function update_value_in_file() {
    var="${1}"
    value="${2}"
    file="${3}"
    # if variable is found in file, update the value
    if grep -q "${var}" "${file}" 2>/dev/null; then
        sed -i "s/${var}=.*/${var}=${value}/" "${file}"
    # else, add the variable and value to the file
    else
        echo "${var}=${value}" >> "${file}"
    fi
}

# get input from user
function get_user_input() {
    # backup values.txt file if exists
    if [ -f "values.txt" ]; then
        cp -f "values.txt" "values.txt.bak"
    fi
    for v in "${@}"; do
        var="${v%=*}"
        default_value="${v#*=}"
        # if variable is not set, get the value from user
        if [ -z "${!var}" ]; then
        # if [ -z "$(read_value_from_file "values.txt" "${var}")" ]; then
            # loop until user input is given
            while [ -z "${!var}" ]; do
            # while [ -z "$(read_value_from_file "values.txt" "${var}")" ]; do
                # override default value if existing value is found in values.txt file
                existing_value=$(read_value_from_file "values.txt" "${var}")
                if [ "${existing_value}" ]; then
                    default_value="${existing_value}"
                else
                    default_value="$(eval echo ${default_value})"
                fi
                # get user input
                read -p "Enter a value for ${var} [${default_value}]: " user_value
                # if user value is given, set the variable to the user value
                if [ "${user_value}" ]; then
                    export "${var}"="${user_value}"
                    update_value_in_file "${var}" "${user_value}" "values.txt"
                # otherwise, if default value is given, set the variable to the default value
                elif [ "${default_value}" ]; then
                    export "${var}"="${default_value}"
                    update_value_in_file "${var}" "${default_value}" "values.txt"
                fi
            done
        fi
    done
}

# get arguments
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -c|--check-env)
            if [ -z "${2}" ]; then
                echo "Please provide an array of environment vars to check!"
                exit 1
            fi
            check_env "${@:2}"
            status="${?}"
            shift
            ;;
        -g|--get-user-input)
            if [ -z "${2}" ]; then
                echo "Please provide an array of environment vars to get user input!"
                exit 1
            fi
            get_user_input "${@:2}"
            status="${?}"
            shift
            ;;
        -r|--read-value-from_file)
            if [ -z "${2}" ]; then
                echo "Please provide the value file name!"
                exit 1
            fi
            if [ -z "${3}" ]; then
                echo "Please provide the variable name!"
                exit 1
            fi
            read_value_from_file "${2}" "${3}"
            status="${?}"
            shift 2
            ;;
        -u|--update-value-in-file)
            if [ -z "${2}" ]; then
                echo "Please provide the variable name!"
                exit 1
            fi
            if [ -z "${3}" ]; then
                echo "Please provide the variable value!"
                exit 1
            fi
            if [ -z "${4}" ]; then
                echo "Please provide the file name to update!"
                exit 1
            fi
            update_value_in_file "${2}" "${3}" "${4}"
            status="${?}"
            shift 3
            ;;
        -h|--help)
            print_help
            status="${?}"
            shift
            ;;
        # *)
        #     echo "Invalid argument: ${1}"
        #     exit 1
        #     ;;
    esac
    shift
done

exit ${status}