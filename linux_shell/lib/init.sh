#!/usr/bin/env bash

LSPWD_2=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${LSPWD_2}/env/init.sh"

source "${LSPWD_2}/log.sh"
source "${LSPWD_2}/system.sh"
source "${LSPWD_2}/action.sh"
source "${LSPWD_2}/action_install.sh"