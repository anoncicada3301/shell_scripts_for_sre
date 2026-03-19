#!/usr/bin/env bash

# 重置所有样式
RESET='\033[0m'

# 常规颜色
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# 亮色（加粗）
BLACK_BOLD='\033[1;30m'
RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
BLUE_BOLD='\033[1;34m'
MAGENTA_BOLD='\033[1;35m'
CYAN_BOLD='\033[1;36m'
WHITE_BOLD='\033[1;37m'

# 背景色
BLACK_BG='\033[40m'
RED_BG='\033[41m'
GREEN_BG='\033[42m'
YELLOW_BG='\033[43m'
BLUE_BG='\033[44m'
MAGENTA_BG='\033[45m'
CYAN_BG='\033[46m'
WHITE_BG='\033[47m'

# 文本样式
BOLD='\033[1m'        # 粗体
DIM='\033[2m'         # 暗淡
ITALIC='\033[3m'      # 斜体
UNDERLINE='\033[4m'   # 下划线
BLINK='\033[5m'       # 闪烁
REVERSE='\033[7m'     # 反显（背景前景互换）
HIDDEN='\033[8m'      # 隐藏