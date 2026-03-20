action() {
    local msg="$1"
    local cmd="$2"
    local width=60
    local result
    
    printf "%-${width}s" "$msg"

    if [ "$cmd" != "true" ] && [ "$cmd" != "false" ]; then
        eval "$cmd" >/dev/null 2>&1 &
        local pid=$!
        local spin='-\|/'
        local i=0
        
        while kill -0 $pid 2>/dev/null; do
            i=$(( (i+1) % 4 ))
            printf "[  ${spin:$i:1}ING   ]\b\b\b\b\b\b\b\b\b\b\b"
            sleep 0.1
        done
        
        wait $pid
        result=$?
    else
        [ "$cmd" = "true" ] && result=0 || result=1
    fi

    printf "\r%-${width}s" "$msg" 
    
    if [ $result -eq 0 ]; then
        echo -e "[   ${GREEN_BOLD}OK${RESET}   ]"
    else
        echo -e "[ ${RED_BOLD}FAILED${RESET} ]"
    fi

    return $result
}