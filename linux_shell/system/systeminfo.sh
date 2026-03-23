#!/usr/bin/env bash

###
# @Author: John.Greg
# @Date: 2026-03-23 16:20:00
# @LastEditTime: 2026-03-23 16:20:00
# @Description: system information check
###

RESET='\033[0m'
 
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
 
_o_info () { echo -e "[${BLUE} INFO ${RESET}]: $1 "; }
_o_notice() { echo -e "[${YELLOW_BOLD} Notice ${RESET}]: $1 "; }
_o_warning() { echo -e "${YELLOW_BOLD}[ Warning ]${RESET}: $1";}
_o_error() { echo -e "${RED_BOLD}[ ERROR ]${RESET}: $1 "; }

_action() {
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
            printf "\r%-${width}s[  ${spin:$i:1}ING   ]" "$msg"
            sleep 0.1
        done
        
        wait $pid
        result=$?
    else
        [ "$cmd" = "true" ] && result=0 || result=1
    fi

    printf "\r%-${width}s" "$msg" 

    
    if [ $result -eq 0 ]; then
        echo -e "[    ${GREEN_BOLD}OK${RESET}    ]"
    else
        echo -e "[  ${RED_BOLD}FAILED${RESET}  ]"
    fi

    return $result
}

_check_root() {
    echo "<==================Initialize environment check====================>"
    if [ "${EUID}" -ne 0 ];then
        _action "Check User" false
        _o_error "User not root, please change root user!"

        echo -e "<======================${RED_BOLD}Program Termination${RESET}=========================>"
        # echo -e "${RED_BOLD}Program   Termination${RESET}"
        echo -e "\n"

        exit 126
    else
        _action "Check User" true
    fi 
    echo "<==================================================================>"
}

_get_system_version() {
    local _system_version_dir_a='/etc/os-release'
    local _system_version_dir_b='/usr/lib/os-release'  

    _pretty_name() { echo -n "System Version: $(awk -F= '/^PRETTY_NAME/ {print $2}' $1 | tr -d '"')"; }
    _version_codename() { echo -e " $(awk -F= '/^VERSION_CODENAME/ {print $2}' $1 | tr -d '"')"; }

    if [ -f "${_system_version_dir_a}" ]; then
        _pretty_name "${_system_version_dir_a}"
        _version_codename "${_system_version_dir_a}"
    elif [ -f "${_system_version_dir_b}" ]; then
        _pretty_name "${_system_version_dir_b}"
        _version_codename "${_system_version_dir_b}"
    else
        _o_error "No found '${_system_version_dir_a}' or '${_system_version_dir_b}'"
    fi
}

_get_cpu() {
    local _cpuinfo_file='/proc/cpuinfo'

    _cpu_name() { echo -e "$( awk -F: '/model name/ {name=$2} END {print name}' $1 | sed 's/^[ \t]*//;s/[ \t]*$//' )"; }
    _cpu_core() { echo -e "$( awk -F: '/model name/ {core++} END {print core}' $1)"; }
    _cpu_freq() { echo -e "$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' $1 | sed 's/^[ \t]*//;s/[ \t]*$//' )"; }
    _cpu_cores_cache() { echo -e "$( awk -F: '/cache size/ {cache=$2} END {print cache}' $1| sed 's/^[ \t]*//;s/[ \t]*$//' )"; }

    echo -n "CPU Name: "
    _cpu_name "${_cpuinfo_file}"

    echo -n "CPU Cores: "
    _cpu_core "${_cpuinfo_file}"

    echo -n "CPU Freq: "
    _cpu_freq "${_cpuinfo_file}"

    echo -n "CPU Cores Cache: "
    _cpu_cores_cache "${_cpuinfo_file}"
}

_get_use_memory() {
    _total_use_mem() { echo -e "$(free -mh | awk '/Mem/ {print $2}')"; }
    _used_use_mem() { echo -e "$(free -mh | awk '/Mem/ {print $3}')"; }
    _avail_use_mem() { echo -e "$(free -mh | awk '/Mem/ {print $7}')"; }

    echo -n "System Total Memory: "
    _total_use_mem
    
    echo -n "System Used Memory: "
    _used_use_mem
    
    echo -n "System Available: "
    _avail_use_mem
}

_get_hard_memory() {

    dmidecode -t memory 2>/dev/null | awk '
        BEGIN { 
            total=0; used=0; sum_gb=0; ecc_type="Unknown"
            printf "%-6s | %-8s | %-5s | %-12s | %-8s | %-15s | %s\n", "Slot", "Size", "Type", "Speed", "ECC", "Vendor", "Serial"
            printf "----------------------------------------------------------------------------------------------------\n"
        }

        /Error Correction Type:/ { ecc_type = $4 " " $5 }
        /Memory Device$/ { total++ }
        /Size: [0-9]/ { size=$2" "$3; raw=$2; unit=$3 }
        /Type: / && !/Error|Correction/ { type=$2 }
        /Speed: [0-9]/ { speed=$2" "$3 }
        /Manufacturer: / { man=$2 }
        /Serial Number: / { serial=$3 }
        /Total Width:/ { total_w = $3 }
        /Data Width:/ { data_w = $3 }

        /Locator: / { 
            if (size ~ /[0-9]/) {
                used++
                if (unit ~ /GB/) { sum_gb += raw }
                else if (unit ~ /MB/) { sum_gb += raw / 1024 }
                is_ecc = (total_w > data_w) ? "Enabled" : "None"
                printf "Slot%-2d | %-8s | %-5s | %-12s | %-8s | %-15s | %s\n", used, size, type, speed, is_ecc, man, (serial ? serial : "Unknown")
                size=""; type=""; speed=""; man=""; serial=""; total_w=0; data_w=0
            }
        }

        END {
            if (total == 0) {
                print "No memory found."
            }
            else {
                printf "----------------------------------------------------------------------------------------------------\n"
                printf "[SUMMARY]\n"
                printf "Total Slots:      %d\n", total
                printf "Used Slots:       %d\n", used
                printf "Free Slots:       %d\n", (total - used)
                printf "Total Capacity:   %.2f GB\n", sum_gb
            }
        }
    '
}

_chek_dmidecode() {
    local _search_paths=("/usr/sbin/dmidecode" "/sbin/dmidecode" "/usr/local/sbin/dmidecode")
    local _dmi_bin=""

    for path in "${_search_paths[@]}"; do
        if [[ -x "$path" ]]; then
            dmi_bin="$path"
            break
        fi
    done

    if [[ -z "$_dmi_bin" ]]; then
        _dmi_bin=$(type -P dmidecode)
    fi

    if [[ -n "$_dmi_bin" ]]; then
        _action "check dmidecode" true
    else
        _action "check dmidecode" false
        _o_error "No Found cpommand dmidecode."
        _o_error "Please install dmidecode package"
        _o_info "If system is Ubuntu/Debian... , use 'apt install' or 'apt-get install'"
        _o_info "If system is Redhat/CentOS... , use 'yum install' or 'dnf install'"
        echo "<=====================Script Terminated======================>"
        exit 1
    fi
}

_get_disk_info() {
    local table_data="Device|Size|Type|Interface|Vendor|Serial"
    local disks=$(lsblk -dno NAME,TYPE | awk '$2=="disk"{print $1}')

    for dev in $disks; do
        local dev_path="/dev/$dev"
        local size=$(lsblk -dno SIZE "$dev_path" | xargs)
        local rota=$(lsblk -dno ROTA "$dev_path")
        local disk_type="HDD"

        [[ "$dev" == nvme* ]] && disk_type="NVMe-SSD" || { [ "$rota" -eq 0 ] && disk_type="SSD"; }

        local smart_info=$(smartctl -i "$dev_path" 2>/dev/null)
        local vendor=$(echo "$smart_info" | grep -E "Model Family|Device Model|Model Number" | head -1 | awk -F: '{print $2}' | xargs | awk '{print $1}')
        local transport=$(echo "$smart_info" | grep "Transport protocol" | awk -F: '{print $2}' | xargs)

        [ -z "$transport" ] && transport="SATA/SAS"

        local serial=$(echo "$smart_info" | grep "Serial Number" | awk -F: '{print $2}' | xargs)

        table_data+="\n$dev_path|${size}|${disk_type}|${transport:-Unknown}|${vendor:-Unknown}|${serial:-Unknown}"
    done

    local formatted_table=$(echo -e "$table_data" | column -s '|' -t)
    local header_line=$(echo "$formatted_table" | head -n 1)
    local line_length=$(echo "$header_line" | wc -L)
    local separator=$(printf '%*s' "$line_length" '' | tr ' ' '-')

    echo "$header_line"
    echo "$separator"
    echo "$formatted_table" | tail -n +2
}

_check_disk_tools() {
    local tools=("lsblk" "smartctl" "awk")
    for tool in "${tools[@]}"; do
        if ! command -v "${tool}" &>/dev/null; then
            _o_error "Command '${tool}' not found. Please install it first."

            case "$tool" in
                smartctl)
                    _o_info "The '${tool}' utility is provided by the 'smartmontools' package."
                    echo "Ubuntu/Debian: apt install smartmontools"
                    echo "CentOS/RHEL:   yum install smartmontools"
                    ;;
                lsblk)
                    _o_info "The '${tool}' utility is typically included in the 'util-linux' package."
                    ;;
            esac
            echo "<=====================Script Terminated======================>"
            exit 1
        else
            _action "Disk Tools [ ${tool} ]" true
        fi
    done
}

_file_output() {
    if [ -n "${_save_path}" ] && [ -d "${_save_path}" ]; then
        return 0
    fi

    local _default_dir="${HOME}"
    local _file_path
    
    read -p "Please in file save path:(Default path is '${HOME}')" _file_path
    
    [ -z "${_file_path}" ] && _file_path="${_default_dir}"

    _file_path="${_file_path/#\~/${HOME}}"

    if [ ! -d "$_file_path" ]; then
        echo "Directory '${_file_path}' does not exist."
        read -p "Do you want to create it? (y/n): " _create
        if [[ "${_create}" =~ ^[Yy]$ ]]; then
            mkdir -p "${_file_path}" || { _o_error "Failed to create directory!"; return 1; }
        else
            _o_error "Save canceled."
            return 1
        fi
    fi

    if [ ! -w "$_file_path" ]; then
        _o_error "Permission denied: Cannot write to '${_file_path}'"
        return 1
    fi

    _save_path="${_file_path}"
    echo "Files will be saved to: ${_save_path}"
}

_print_info() {
    local _mssg="$1"
    local _comd="$2"
    local _file_name="$3"
    
    if ! _file_output; then
        return 1
    fi

    local _full_path="${_save_path}/${_file_name}"

    _action "${_mssg}" "${_comd} > '${_full_path}'"
    
    echo ''
    echo "Success: Report saved to '${_full_path}'"
    return 0
    echo ''
}

_output_all_list() {
    echo "<========================== Export All List ===========================>"
    
    local _file_name="all_system_report_$(date +%Y%m%d).txt"
    local _combined_cmd="(
        echo '--- [1] System Version ---'; _get_system_version; echo '';
        echo '--- [2] CPU Information ---'; _get_cpu; echo '';
        echo '--- [3] System Memory ---'; _get_use_memory; echo '';
        if [ \$(id -u) -eq 0 ]; then
            echo '--- [4] Hard Memory Info (ROOT) ---'; _get_hard_memory; echo '';
            echo '--- [5] Disk Information (ROOT) ---'; _get_disk_info; echo '';
        else
            echo '--- [!] ROOT Required: Hard Memory & Disk Info Skipped ---'; echo '';
        fi
    )"

    _print_info "Exporting All System Information" "${_combined_cmd}" "${_file_name}"

    echo "<======================================================================>"
}

_options() {
    echo "<==================System Info Check Script==================>"

    echo '''
    [1] System Version Check
    [2] CPU Information check
    [3] System Memory Check
    [4] Hard Memory Info Check ( Need ROOT )
    [5] Disk Info Check ( Need ROOT )
    [6] Print Info
    [0] exit
    '''
    echo "<============================================================>"
}

_print_options() {
    echo "<==================System Info Check Script==================>"
    echo "<======================= Print Info =========================>"
    echo '''
    [1] Print System Version List
    [2] Print CPU Information List
    [3] Print System Memory List
    [4] Print Hard Memory Info List
    [5] Print Disk Info List
    [6] Print All List
    [8] Unset Save Path
    [9] back
    [0] exit
    '''
    echo "<============================================================>"
}

_options_input() {
    echo ''

    if ! read -t 8 -p "Please input option (Auto-exit in 8 seconds): " $1; then
        echo ''
        _o_error 'Time Out!'
        echo "<=====================Script Terminated======================>"
        exit 0
    fi
    
    echo ''
}

_hd_mem_info() {
    echo "<=============================Tools Check==============================>"
    if _chek_dmidecode; then
        echo "<======================================================================>"
        echo ''
        echo "<======================Hard Memory Info======================>"
        _get_hard_memory
        echo "<============================================================>"
    fi
    
    echo ''
}

_disk_info() {
    echo "<===============================Tools Check================================>"
    if _check_disk_tools; then
        echo "<==========================================================================>"
        echo ''
        echo "<================================Disk Info=================================>"
        _get_disk_info
        echo "<==========================================================================>"
    fi

    echo ''
}

_auto_exit() {
    echo "Press any key to continue (Auto-exit in 15 seconds)..."

    if ! read -t 15 -n 1 -s; then
        _o_error 'Time Out!'
        echo "<=====================Script Terminated======================>"
        exit 0
    fi
}

main() {
    while true; do
        clear
        _options
        _options_input _options_m

        case "${_options_m}" in
            1)
                echo "<================== System Version Info =================>"
                _get_system_version
                echo "<========================================================>"
                _auto_exit
                echo ''
                clear
                ;;
            2)
                echo "<================== CPU Info ==================>"
                _get_cpu
                echo "<==============================================>"
                _auto_exit
                echo ''
                clear
                ;;
            3)
                echo "<==================System Memory Info==================>"
                _get_use_memory
                echo "<======================================================>"
                _auto_exit
                echo ''
                clear
                ;;
            4)

                if _check_root; then
                    echo ''
                    _hd_mem_info | less -RFX | tr -d '\r'
                fi
                _auto_exit
                echo ''
                clear
                ;;
            5)
                if _check_root; then
                    echo ''
                    _disk_info | less -RFX | tr -d '\r'
                fi
                _auto_exit
                echo ''
                clear
                ;;
            6)  
                while true; do
                    clear
                    _print_options
                    _options_input _options_s

                    case "${_options_s}" in
                        1)
                            echo "<=======================System Memory Info=======================>"
                            _print_info "Exporting System Version" "_get_system_version" "system_version_$(date +%Y%m%d).txt" || { continue; }
                            echo "<================================================================>"
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        2)
                            echo "<========================CPU Information=========================>"
                            _print_info "Exporting CPU Information" "_get_cpu" "cpu_info_$(date +%Y%m%d).txt" || { continue; }
                            echo "<================================================================>"
                            echo ''                         
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        3)
                            echo "<===================System Memory Information=====================>"
                            _print_info "Exporting CPU Information" "_get_use_memory" "sys_mem_info_$(date +%Y%m%d).txt" || { continue; }
                            echo "<================================================================>"
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        4)
                            echo "<=====================Hard Memory Information=====================>"
                            if _check_root; then
                                if _chek_dmidecode; then
                                    _print_info "Exporting Hard Memory Information" "_get_hard_memory" "hd_mem_info_$(date +%Y%m%d).txt" || { continue; }
                                fi
                            fi
                            echo "<================================================================>"
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        5)
                            echo "<========================Disk Information=========================>"
                            if _check_root; then
                                if _check_disk_tools;then
                                    _print_info "Exporting Disk Information" "_get_disk_info" "disk_info_$(date +%Y%m%d).txt" || { continue; }
                                fi
                            fi
                            echo "<================================================================>"
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        6)
                            _output_all_list
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        8)
                            unset _save_path
                            echo "Save path has been reset. You will be asked for a new path on next export."
                            echo ''
                            _auto_exit
                            echo ''
                            clear
                            ;;
                        9)
                            break
                            ;;
                        0)
                            echo "<==========================Script exited===========================>"
                            echo ''
                            exit 0
                            ;;
                        *)
                            _o_error "Input is unavailable!"
                            sleep 1.5
                            echo ''
                            continue
                            ;;
                    esac
                done
                ;;
            0)
                echo "<==========================Script exited===========================>"
                echo ''
                exit 0
                ;;
            *)
                _o_error "Input is unavailable!"
                sleep 1.5
                echo ''
                continue
                ;;
        esac
    done
}

main