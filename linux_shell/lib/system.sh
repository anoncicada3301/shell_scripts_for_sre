#!/usr/bin/env bash

check_root() {
    if [ "${EUID}" -ne 0 ];then
        action "Check User" false
        echo -e "${RED_BOLD}[ ERROR ]: User not root, please change user! ${RESET}"

        # echo -e "\a"  # The prompt sound may not be enabled
        
        return 126
        exit 0
        
    else
        action "Check User" true
    fi
    
}