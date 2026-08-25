#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

monitor_instance(){

    echo
    echo "========================================"
    echo "            EC2 Monitoring              "
    echo "========================================"
    echo

    INSTANCE_ID=$(get_instance_id)

    CURRENT_STATE=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].State.Name' \
        --output text)

    echo "Instance: $INSTANCE_ID"
    echo "State: $CURRENT_STATE"
    echo

    if [ "$CURRENT_STATE" != "running" ]; then
        echo "Status: Instance is not running."
        exit 1
    fi

    echo "fetching Cloudwatch metrics..."
    echo 

    START_TIME=$(date -u -d '10 minutes ago' '+%Y-%m-%dT%H:%M:%SZ')
    END_TIME=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    CPU=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/EC2 \
        --metric-name CPUUtilization \
        --dimensions Name=InstanceId.Value="$INSTANCE_ID" \
        --statistics Average \
        --period 300 \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --query 'Datapoints | sort_by(@, &Timestamp) | [-1].Average' \
        --output text)

    if [ "$CPU" = "None" ]; then
        CPU="No data"
    fi

    echo "CPU Utilization: $CPU%" 

    if [ "$CPU" != "No data" ]; then
        if(($(echo "$CPU > 80" |bc -l) )); then
            echo
            echo "Status: WARNING -High CPU usage!"

            log "WARNING: High CPU usage detected: $CPU%"

        else
            echo
            echo "Status: HEALTHY"

            log "EC2 health check passed. CPU: $CPU%"
        fi

    fi

}