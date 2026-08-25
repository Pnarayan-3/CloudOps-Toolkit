#!/bin/bash
##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

########################################
# CloudOps Configuration Validation
########################################

validate_config() {

    echo
    echo "========================================"
    echo "       CLOUDOPS CONFIGURATION"
    echo "========================================"
    echo

    CONFIG_STATUS=0


    ########################################
    # AWS Region
    ########################################

    if [ -n "${AWS_REGION:-}" ]; then

        echo -e "AWS Region          ${GREEN}✓${NC}"

    else

        echo -e "AWS Region          ${RED}✗${NC}"

        CONFIG_STATUS=1

    fi


    ########################################
    # S3 Bucket
    ########################################

    if [ -n "${BUCKET_NAME:-}" ]; then

        echo -e "S3 Bucket           ${GREEN}✓${NC}"

    else

        echo -e "S3 Bucket           ${RED}✗${NC}"

        CONFIG_STATUS=1

    fi


    ########################################
    # Backup Source
    ########################################

    if [ -d "$SCRIPT_DIR/$BACKUP_SOURCE" ]; then

        echo -e "Backup Source       ${GREEN}✓${NC}"

    else

        echo -e "Backup Source       ${RED}✗${NC}"

        CONFIG_STATUS=1

    fi


    ########################################
    # Backup Directory
    ########################################

    if [ -d "$SCRIPT_DIR/$BACKUP_DIR" ]; then

        echo -e "Backup Directory    ${GREEN}✓${NC}"

    else

        echo -e "Backup Directory    ${YELLOW}!${NC}"

        echo "                   Directory will be created when needed."

    fi


    ########################################
    # Log File
    ########################################

    LOG_DIRECTORY=$(dirname "$SCRIPT_DIR/$LOG_FILE")

    if [ -d "$LOG_DIRECTORY" ]; then

        echo -e "Log Directory       ${GREEN}✓${NC}"

    else

        echo -e "Log Directory       ${YELLOW}!${NC}"

        echo "                    Directory will be created when needed."

    fi


    ########################################
    # Retention Days
    ########################################

    if [[ "${BACKUP_RETENTION_DAYS:-}" =~ ^[0-9]+$ ]] &&
       [ "$BACKUP_RETENTION_DAYS" -gt 0 ]; then

        echo -e "Retention Days      ${GREEN}✓${NC}"

    else

        echo -e "Retention Days      ${RED}✗${NC}"

        CONFIG_STATUS=1

    fi


    ########################################
    # Overall Result
    ########################################

    echo
    echo "========================================"

    if [ "$CONFIG_STATUS" -eq 0 ]; then

        echo -e "Overall Status: ${GREEN}VALID${NC}"

        log "Configuration validation: VALID"

    else

        echo -e "Overall Status: ${RED}INVALID${NC}"

        log "Configuration validation: INVALID"

    fi

    echo "========================================"
    echo

    return "$CONFIG_STATUS"
}