#!/bin/bash

##############################
## Author: Pushkar Narayan  ##
## Date: 2026-08-25         ##
##############################

#!/bin/bash

generate_report() {

    echo
    echo "========================================"
    echo "          AWS RESOURCE REPORT"
    echo "========================================"
    echo

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    FILE_TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

    REPORT_FILE="$SCRIPT_DIR/reports/aws-report-$FILE_TIMESTAMP.txt"

    mkdir -p "$SCRIPT_DIR/reports"

    {
        echo "========================================"
        echo "          AWS RESOURCE REPORT"
        echo "========================================"
        echo
        echo "Generated: $TIMESTAMP"
        echo

        ########################################
        # EC2 REPORT
        ########################################

        echo "EC2"
        echo "----------------------------------------"

        RUNNING=$(aws ec2 describe-instances \
            --filters "Name=instance-state-name,Values=running" \
            --query 'Reservations[].Instances[].InstanceId' \
            --output text)

        STOPPED=$(aws ec2 describe-instances \
            --filters "Name=instance-state-name,Values=stopped" \
            --query 'Reservations[].Instances[].InstanceId' \
            --output text)

        if [ -z "$RUNNING" ]; then
            RUNNING_COUNT=0
        else
            RUNNING_COUNT=$(echo "$RUNNING" | wc -w)
        fi

        if [ -z "$STOPPED" ]; then
            STOPPED_COUNT=0
        else
            STOPPED_COUNT=$(echo "$STOPPED" | wc -w)
        fi

        TOTAL_COUNT=$((RUNNING_COUNT + STOPPED_COUNT))

        echo "Running Instances : $RUNNING_COUNT"
        echo "Stopped Instances : $STOPPED_COUNT"
        echo "Total Instances   : $TOTAL_COUNT"
        echo

        ########################################
        # S3 REPORT
        ########################################

        echo "S3"
        echo "----------------------------------------"

        BUCKETS=$(aws s3api list-buckets \
            --query 'Buckets[].Name' \
            --output text)

        if [ -z "$BUCKETS" ]; then

            echo "No S3 buckets found."

        else

            for BUCKET in $BUCKETS; do

                OBJECT_COUNT=$(aws s3api list-objects-v2 \
                    --bucket "$BUCKET" \
                    --query 'KeyCount' \
                    --output text)

                echo "Bucket  : $BUCKET"
                echo "Objects : $OBJECT_COUNT"
                echo

            done

        fi

        ########################################
        # END REPORT
        ########################################

        echo "========================================"
        echo "Report generation completed."
        echo "========================================"

    } > "$REPORT_FILE"

    cat "$REPORT_FILE"

    echo
    echo "Report saved to:"
    echo "$REPORT_FILE"

    log "AWS resource report generated: $REPORT_FILE"
}