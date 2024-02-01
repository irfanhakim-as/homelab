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
# tpl: Simple templating utility.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help message
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -i, --interpret         Interpret template file and replace values."
    echo "  -h, --help              Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# replace template with values
function interpret_tpl() {
    # get template file
    tpl_file="${1}"
    # get value file
    value_file="${2}"
    # get template file content
    tpl_content="$(cat "${tpl_file}")"
    # replace placeholders denote by {{}} with values
    for placeholder in $(echo "${tpl_content}" | grep -o -P "{{.*?}}"); do
        # remove {{ and }} from placeholder
        placeholder="$(echo "${placeholder}" | sed -e 's/^{{//' -e 's/}}$//')"
        # get value from values passed to the function
        # value="$(echo "${@:2}" | grep -o "${placeholder}=[^ ]*" | sed -e "s/${placeholder}=//")"
        value="$(${SOURCE_DIR}/../helpers/utils.sh --input --read-value-from_file "${value_file}" "${placeholder}")"
        # replace placeholder with value if value is not empty
        if [ "${value}" ]; then
            tpl_content="$(echo "${tpl_content}" | sed -e "s/{{${placeholder}}}/${value}/")"
        fi
    done
    # write template content to file
    echo "${tpl_content}" > "${tpl_file}"
}

# get arguments
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -i|--interpret)
            if [ -z "${2}" ]; then
                echo "Please provide the template file!"
                exit 1
            fi
            interpret_tpl "${@:2}"
            shift
            ;;
        -h|--help)
            print_help
            shift
            ;;
        # *)
        #     echo "Invalid argument: ${1}"
        #     exit 1
        #     ;;
    esac
    shift
done