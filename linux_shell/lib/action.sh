#!/usr/bin/env bash

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