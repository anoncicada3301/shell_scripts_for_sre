#!/usr/bin/env bash

###
# @Author: John.Greg
# @Date: 2026-03-19 14:00:00
# @LastEditTime: 2026-03-19 14:00:00
# @Description: Ports Check
###

RESET='\033[0m'
 
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
 
o_info () { echo -e "[${BLUE} INFO ${RESET}]: $1 "; }
o_notice() { echo -e "[${YELLOW_BOLD} Notice ${RESET}]: $1 "; }
o_warning() { echo -e "${YELLOW_BOLD}[ Warning ]${RESET}: $1";}
o_error() { echo -e "${RED_BOLD}[ ERROR ]${RESET}: $1 "; }
a_error() { echo -e "${RED_BOLD}[ ERROR ]: $1 ${RESET}"; }
prf_chk_sev() { echo -e "${YELLOW_BOLD}Please check your service. ${RESET}"; }

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
    echo -e "\n"
}

ports_test_port() {
    local services_ports=$1

    local tcp_port=$(ss -ntlp | awk '{print $4}' | awk -F':' '{print $2}' | grep -w "${services_ports}")
    local udp_port=$(ss -nulp | awk '{print $4}' | awk -F':' '{print $2}' | grep -w "${services_ports}")
    local service_name=$(ss -ntulp | grep -w "${services_ports}" | awk '{print $7}' | awk -F'"' '{print $2}' | head -n 1)
    
    [ -z "${service_name}" ] && service_name="$(echo -e ${YELLOW}Unkown${RESET})"

    echo -e "<=================Ports Check Requst [${service_name}]======================>"

    if [ -z "${tcp_port}" ] && [ -z "${udp_port}" ]; then
        action "Service Port: ${services_ports}" false
        o_warning "The service port is not active or does not exist!"
        prf_chk_sev
    else
        if [ "${services_ports}" == "${tcp_port}" ]; then
            action "Service Port: ${services_ports}/tcp" true
        fi

        if [ "${services_ports}" == "$udp_port" ]; then
            action "Service Port: ${services_ports}/udp" true
        fi
    fi
    echo "<==================================================================>"
    echo -e "\n"
}

input_port() {
    local prompt='Please input ports:'
    local port_chk
    local result

    o_info "Multiple values please separated by spaces."
    read -p "${prompt}" -a result
    echo -e "\n"
    
    if [ "${#result}" -eq 0 ]; then
        o_notice "Input type is Null!"
    fi

    for port_chk in "${result[@]}"; do
        if [[ "${port_chk}" =~ ^[1-9][0-9]*$ ]]; then
            if (( "${port_chk}" >= 1 && "${port_chk}" <= 65535 ));then
                ports_test_port "${port_chk}" 
            else
                o_notice "Input ports unavailable!"
                exit 1
                # break
            fi
        else
            o_notice "Input type invalid!"
            exit 1
            # break
        fi
    done

}

main() {
    if check_root; then
        input_port
    fi
}

main