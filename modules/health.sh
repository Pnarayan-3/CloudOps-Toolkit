#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

#!/bin/bash

########################################
# CloudOps Health Check
########################################

health_check() {

    echo
    echo "========================================"
    echo "        CLOUDOPS HEALTH CHECK"
    echo "========================================"
    echo

    HEALTH_STATUS=0


    ########################################
    # AWS CLI
    ########################################

    if command -v aws &> /dev/null; then

        echo -e "AWS CLI              ${GREEN}✓${NC}"

    else

        echo -e "AWS CLI              ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # AWS Credentials
    ########################################

    if aws sts get-caller-identity &> /dev/null; then

        echo -e "AWS Credentials      ${GREEN}✓${NC}"

    else

        echo -e "AWS Credentials      ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # AWS Account
    ########################################

    ACCOUNT_ID=$(aws sts get-caller-identity \
        --query 'Account' \
        --output text 2>/dev/null || true)

    if [ -n "$ACCOUNT_ID" ] && [ "$ACCOUNT_ID" != "None" ]; then

        echo -e "AWS Account          ${GREEN}✓${NC}"

    else

        echo -e "AWS Account          ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # S3 Bucket
    ########################################

    if aws s3api head-bucket \
        --bucket "$BUCKET_NAME" \
        &> /dev/null; then

        echo -e "S3 Bucket            ${GREEN}✓${NC}"

    else

        echo -e "S3 Bucket            ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # EC2 Access
    ########################################

    if aws ec2 describe-instances \
        --max-results 1 \
        &> /dev/null; then

        echo -e "EC2 Access           ${GREEN}✓${NC}"

    else

        echo -e "EC2 Access           ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # CloudWatch Access
    ########################################

    if aws cloudwatch list-metrics \
        --namespace AWS/EC2 \
        --max-results 1 \
        &> /dev/null; then

        echo -e "CloudWatch Access    ${GREEN}✓${NC}"

    else

        echo -e "CloudWatch Access    ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # Backup Directory
    ########################################

    if [ -d "$BACKUP_DIR" ]; then

        echo -e "Backup Directory     ${GREEN}✓${NC}"

    else

        echo -e "Backup Directory     ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # Log Directory
    ########################################

    LOG_DIRECTORY=$(dirname "$LOG_FILE")

    if [ -d "$LOG_DIRECTORY" ]; then

        echo -e "Log Directory        ${GREEN}✓${NC}"

    else

        echo -e "Log Directory        ${RED}✗${NC}"

        HEALTH_STATUS=1

    fi


    ########################################
    # Overall Result
    ########################################

    echo
    echo "========================================"

    if [ "$HEALTH_STATUS" -eq 0 ]; then

        echo -e "Overall Status: ${GREEN}HEALTHY${NC}"

        log "CloudOps health check: HEALTHY"

    else

        echo -e "Overall Status: ${RED}UNHEALTHY${NC}"

        log "CloudOps health check: UNHEALTHY"

    fi

    echo "========================================"
    echo

    return "$HEALTH_STATUS"
}