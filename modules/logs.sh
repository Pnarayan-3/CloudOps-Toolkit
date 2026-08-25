#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

log() {

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}


show_logs() {

    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file found."
        return
    fi

    echo "================================"
    echo "       CloudOps Activity Log"
    echo "================================"
    echo

    cat "$LOG_FILE"
}