#!/usr/bin/env bash

timer_start() {
    __TIMER_START=$(date +%s%N)
}

timer_end() {
    local end=$(date +%s%N)
    echo $(( (end - __TIMER_START) / 1000000 ))  # 毫秒
}