#!/usr/bin/env bash

log_info() {
    echo -e "[${BLUE}INFO${RESET}] $*";
}

log_warn() {
    echo -e "[${YELLOW}WARN${RESET}] $*";
}

log_error() {
    echo -e "[${RED}ERROR${RESET}] $*" >&2;
}
log_success() {
    echo -e "[${GREEN}SUCCESS${RESET}] $*";
}


o_info () { echo -e "[${BLUE} INFO ${RESET}]: $1 "; }
o_notice() { echo -e "[${YELLOW_BOLD} Notice ${RESET}]: $1 "; }
o_warning() { echo -e "${YELLOW_BOLD}[ Warning ]${RESET}: $1";}
o_error() { echo -e "${RED_BOLD}[ ERROR ]${RESET}: $1 "; }
a_error() { echo -e "${RED_BOLD}[ ERROR ]: $1 ${RESET}"; }