#!/bin/bash

##############################
## Author: Pushkar Narayan  ##
## Date: 2026-08-25         ##
##############################

########################################
# CloudOps Error Handler
########################################

error_handler() {

    local EXIT_CODE=$?
    local LINE_NUMBER=$1
    local COMMAND=$2

    echo
    echo "========================================"
    echo -e "${RED}          CLOUDOPS ERROR${NC}"
    echo "========================================"
    echo
    echo "Command   : $COMMAND"
    echo "Exit Code : $EXIT_CODE"
    echo "Line      : $LINE_NUMBER"
    echo
    echo "Check logs/cloudops.log for details."
    echo
    echo "========================================"
    echo

    if command -v log &> /dev/null; then

        log "ERROR: Command failed"
        log "ERROR: Command: $COMMAND"
        log "ERROR: Exit code: $EXIT_CODE"
        log "ERROR: Line: $LINE_NUMBER"

    fi

    exit "$EXIT_CODE"
}