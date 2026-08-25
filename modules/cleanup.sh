#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

cleanup_local_backups() {

    echo
    echo "Checking local backups..."
    echo

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Backup directory does not exist."
        return
    fi

    OLD_FILES=$(find "$BACKUP_DIR" \
        -type f \
        -name "*.tar.gz" \
        -mtime +"$BACKUP_RETENTION_DAYS")

    if [ -z "$OLD_FILES" ]; then
        echo "No old local backups found."
        return
    fi

    echo "Old local backups found:"
    echo

    echo "$OLD_FILES"

    echo
    read -r -p "Delete these local backups? (y/n): " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Local cleanup cancelled."
        return
    fi

    while IFS= read -r FILE; do

        rm -f "$FILE"

        echo "Deleted: $FILE"

        log "Deleted old local backup: $FILE"

    done <<< "$OLD_FILES"

    echo
    echo "Local backup cleanup completed."
}

cleanup_s3_backups() {

    echo
    echo "Checking S3 backups..."
    echo

    OBJECTS=$(aws s3api list-objects-v2 \
        --bucket "$BUCKET_NAME" \
        --query "Contents[?LastModified<=\`$(date -u -d "$BACKUP_RETENTION_DAYS days ago" '+%Y-%m-%dT%H:%M:%SZ')\`].Key" \
        --output text)

    if [ -z "$OBJECTS" ] || [ "$OBJECTS" = "None" ]; then
        echo "No old S3 backups found."
        return
    fi

    echo "Old S3 backups found:"
    echo

    echo "$OBJECTS"

    echo
    read -r -p "Delete these S3 backups? (y/n): " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "S3 cleanup cancelled."
        return
    fi

    for OBJECT in $OBJECTS; do

        if [ "$DRY_RUN" = true ]; then

            echo "  Would delete: s3://$BUCKET_NAME/$OBJECT"

        else

            aws s3 rm "s3://$BUCKET_NAME/$OBJECT"

            log "Deleted S3 object: s3://$BUCKET_NAME/$OBJECT"

        fi

    done

    echo
    echo "S3 backup cleanup completed."
}

cleanup_resources() {

    local DRY_RUN=false

    if [[ "${1:-}" == "--dry-run" ]]; then
        DRY_RUN=true
    fi

    echo
    echo "========================================"

    if [ "$DRY_RUN" = true ]; then
        echo "          CLEANUP - DRY RUN"
    else
        echo "          BACKUP CLEANUP"
    fi

    echo "========================================"
    echo

    echo "Retention period: $BACKUP_RETENTION_DAYS days"
    echo

    OLD_FILES=$(find "$BACKUP_DIR" \
        -type f \
        -mtime +"$BACKUP_RETENTION_DAYS" \
        2>/dev/null || true)


    if [ -z "$OLD_FILES" ]; then

        echo -e "${GREEN}No old backups found.${NC}"

        return 0

    fi


    echo "Files identified for cleanup:"
    echo

    while IFS= read -r FILE; do

        [ -z "$FILE" ] && continue

        echo "  $FILE"

    done <<< "$OLD_FILES"


    echo


    ########################################
    # DRY RUN
    ########################################

    if [ "$DRY_RUN" = true ]; then

        echo -e "${YELLOW}DRY RUN: No files were deleted.${NC}"

        return 0

    fi


    ########################################
    # Actual Cleanup
    ########################################

    read -r -p "Delete these files? (y/n): " CONFIRM


    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then

        echo "Cleanup cancelled."

        return 0

    fi


    while IFS= read -r FILE; do

        [ -z "$FILE" ] && continue

        rm -f "$FILE"

        echo "Deleted: $FILE"

        log "Deleted old backup: $FILE"

    done <<< "$OLD_FILES"


    echo
    echo -e "${GREEN}Cleanup completed successfully.${NC}"
}