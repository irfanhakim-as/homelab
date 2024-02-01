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
# utils: Utility functions.

# get script source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# print help message
function print_help() {
    echo "Usage: ${0} [OPTIONS]"; echo
    echo "OPTIONS:"
    echo "  -i, --input             Utility pertaining user input and values."
    echo "  -s, --sysfetch          Fetch system configuration."
    echo "  -t, --tpl               Simple templating utility."
    echo "  -h, --help              Show this help message."; echo
    echo "Report bugs to https://github.com/irfanhakim-as/homelab/issues"
}

# get arguments
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -i|--input)
            ${SOURCE_DIR}/../utils/input.sh "${@:2}"
            shift
            ;;
        -s|--sysfetch)
            ${SOURCE_DIR}/../utils/sysfetch.sh "${@:2}"
            shift
            ;;
        -t|--tpl)
            ${SOURCE_DIR}/../utils/tpl.sh "${@:2}"
            shift
            ;;
        -h|--help)
            print_help
            shift
            ;;
    esac
    shift
done