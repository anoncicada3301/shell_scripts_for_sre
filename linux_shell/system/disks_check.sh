#!/usr/bin/env bash

###
# @Author: John.Greg
# @Date: 2026-03-19 10:09:00
# @LastEditTime: 2026-03-19 10:09:00
# @Description: Disks Check
###

RESET='\033[0m'
 
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
 
o_info () { echo -e "[${BLUE} INFO ${RESET}]: $1 "; }
o_warning() { echo -e "${YELLOW_BOLD}[ Warning ]${RESET}: $1"; }
a_error() { echo -e "${RED_BOLD}[ ERROR ]: $1 ${RESET}"; }

action() {
    local msg="$1"
    local cmd="$2"
    local result
    local width=60
 
    if [ "$cmd" != "true" ] && [ "$cmd" != "false" ]; then
        eval "$cmd" >/dev/null 2>&1
        result=$?
    else
        result=$([ "$cmd" = "true" ] && echo 0 || echo 1)
    fi
 
    printf "%-${width}s" "$msg"
    if [ $result -eq 0 ]; then
        echo -e "[${GREEN_BOLD}  OK  ${RESET}]"
    else
        echo -e "[ ${RED_BOLD}FAILED${RESET} ]"
    fi                                                                                                                             
 
    return $result
}

check_root() {
    echo "<==================Initialize environment check====================>"
    if [ "${EUID}" -ne 0 ];then
        action "Check User" false
        a_error "User not root, please change user!"

        echo -e "<==================================================================>"
        echo -e "${RED_BOLD}Program   Termination${RESET}"
        echo -e "\n"

        exit 126
    else
        action "Check User" true
    fi 
    echo "<==================================================================>"
}

# show disks
show_disks() {
    (
        df -hP | head -1
        df -h | \
        grep -iE "^/dev/" | \
        grep -v "tmpfs" | \
        grep -vE "boot" | \
        grep -vE "loop"
    )
}

# get disks usage list
get_disk_usage_list() {
    (
        show_disks | \
        tail -n +2 | \
        awk '{print $(NF-1), $NF}' | \
        tr -d '%'
    )
}

# check
check_disks() {
    local _limit='75'

    get_disk_usage_list | while read -r usage mount; do
        [[ -z "${usage}" ]] && continue

        case "${usage}" in
            *[!0-9]*)
                a_error " Invalid value ["${usage}"]"
                ;;
            *)
                if (( ${usage} >= ${_limit} )); then 
                    o_warning "Disk ["${mount}"] will be full! Usage: "${usage}"%"
                else 
                    o_info "Disk ["${mount}"] is normal. Usage: "${usage}"%"
                fi
                ;;
        esac
    done
}

# main
main() {
    echo -e "\n"
    if check_root; then
        echo -e "\n"
        echo "<=========================Disks check==============================>"
        check_disks
        echo "<==================================================================>"
        echo -e "\n"
    fi
}

main
