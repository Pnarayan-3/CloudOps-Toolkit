#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

backup_files() {

    echo "================================"
    echo "       CloudOps S3 Backup"
    echo "================================"
    echo

    if [ ! -d "$BACKUP_SOURCE" ]; then
        echo "Error: Backup source directory not found:"
        echo "$BACKUP_SOURCE"
        exit 1
    fi

    mkdir -p "$BACKUP_DIR"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)

    BACKUP_FILE="backup_$TIMESTAMP.tar.gz"

    echo "Source: $BACKUP_SOURCE"
    echo "Backup: $BACKUP_FILE"
    echo

    echo "Compressing files..."

    tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$BACKUP_SOURCE"

    echo "Compression completed."
    echo

    echo "Uploading to S3..."

    aws s3 cp \
        "$BACKUP_DIR/$BACKUP_FILE" \
        "s3://$BUCKET_NAME/"

    echo
    echo "Backup uploaded successfully."

    log "Backup uploaded: $BACKUP_FILE"

    echo
    echo "Verifying upload..."

    aws s3api head-object \
        --bucket "$BUCKET_NAME" \
        --key "$BACKUP_FILE" \
        > /dev/null

    echo "Backup verification successful."

    log "Backup verification successful: $BACKUP_FILE"
}