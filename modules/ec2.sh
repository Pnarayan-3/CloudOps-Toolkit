#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

get_instance_id(){

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
                  "Name=instance-state-name,Values=pending,running,stopping,stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)


    INSTANCE_COUNT=$(echo "$INSTANCE_ID" | wc -w)

    if [ "$INSTANCE_COUNT" -eq 0 ]; then
        echo "Error:No EC2 instance found with Name=$INSTANCE_NAME"
        exit 1
    fi

    if [ "$INSTANCE_COUNT" -gt 1 ]; then
        echo "Error:Multiple EC2 instances found with Name=$INSTANCE_NAME"
        echo "Please use a unique Name tag."
        exit 1
    fi 

    echo "$INSTANCE_ID"

}

show_status(){
    echo "Checking EC2 instances......"
    echo 

    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
        --query 'Reservations[*].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType,IP:PublicIpAddress}'  \
        --output table
}

start_instance(){
    echo  "Finding EC2 instance..."

    INSTANCE_ID=$(get_instance_id)

    CURRENT_STATE=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Resservations[0].Instances[0].State.Name' \
        --output text)

    echo "Instance: $INSTANCE_ID"
    echo "Current state: $CURRENT_STATE"
    echo

    if [ "$CURRENT_STATE" = "running" ]; then
        echo "Instance is already running."
        exit 0
    fi

    if [ "$CURRENT_STATE" != "stopped" ]; then
        echo "Instance cannot be started from state: $CURRENT_STATE"
        exit 1
    fi

    echo "Starting instance..."

    aws ec2 start-instances \
        --instance-ids "$INSTANCE_ID" \
        --output table


    log "Starting EC2 instance: $INSTANCE_ID"
    
    echo
    echo "Waiting for instance to become running..."

    aws ec2 wait instance-running \
        --instance-ids "$INSTANCE_ID"

    echo
    echo -e "${GREEN}Instance is now RUNNING.${NC}"

    log "EC2 instance started successfully: $INSTANCE_ID"
}

stop_instance(){

    echo  "Finding EC2 instance..."

    INSTANCE_ID=$(get_instance_id)

    CURRENT_STATE=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Resservations[0].Instances[0].State.Name' \
        --output text)

    echo "Instance: $INSTANCE_ID"
    echo "Current state: $CURRENT_STATE"
    echo

    if [ "$CURRENT_STATE" = "stopped" ]; then
        echo "Instance is already stopped."
        exit 0
    fi

    if [ "$CURRENT_STATE" != "running" ]; then
        echo "Instance cannot be stopped from state: $CURRENT_STATE"
        exit 1
    fi

    read -r -p "Are you sure you want to stop this instance? (y/n): " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then 
        echo "Operation cancelled."
        exit 0
    fi

    echo
    echo "Stopping instance..."
    log "Stopping EC2 instance: $INSTANCE_ID"

    aws ec2 stop-instances \
        --instance-ids "$INSTANCE_ID" \
        --output table

    echo
    echo "Waiting for instance to stop..."

    aws ec2 wait instance-stopped \
        --instance-ids "$INSTANCE_ID"

    echo
    echo "Instance is now STOPPED."
    log "EC2 instance stopped successfully: $INSTANCE_ID"

}
