#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################
########################################
# CloudOps Automated Backup
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/cloudops.sh" backup >> "$SCRIPT_DIR/logs/cron.log" 2>&1