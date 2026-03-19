#!/usr/bin/env bash

action_install () {
    if [ "$1" == "$2" ]; then
        echo -e "[${BLUE} INFO ${RESET}]: None thing to do."
        echo -e "[${BLUE} INFO ${RESET}]: $3 are already exist."
    else
        echo -e "${RED_BOLD}[ Notice ]:When installing, do not operate any keyboard or mouse! ${RESET}"
        echo -e "${YELLOW_BOLD}Installing! Please hold on! ${RESET}"
        action "Install Net-Tools" "yum install -y $2"
    fi
}