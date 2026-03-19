#!/usr/bin/env bash

error_exit () {
    echo -e "\n"
    echo -e "${RED_BOLD}Program   Termination${RESET}"
    echo "=========================================="
    echo -e "\n"
    exit 1
}