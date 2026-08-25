#!/bin/bash

##############################
## Author:Pushkar Narayan   ##
## Date: 2026-08-25         ##
##############################

#!/bin/bash

configure_s3_lifecycle() {

    echo
    echo "========================================"
    echo "       S3 Lifecycle Configuration"
    echo "========================================"
    echo

    echo "Bucket: $BUCKET_NAME"
    echo "Retention: $S3_LIFECYCLE_DAYS days"
    echo

    read -r -p "Apply this lifecycle policy? (y/n): " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Lifecycle configuration cancelled."
        return
    fi

    echo
    echo "Creating lifecycle policy..."

    LIFECYCLE_FILE=$(mktemp)

    cat > "$LIFECYCLE_FILE" <<EOF
{
    "Rules": [
        {
            "ID": "CloudOpsBackupRetention",
            "Status": "Enabled",
            "Filter": {
                "Prefix": ""
            },
            "Expiration": {
                "Days": $S3_LIFECYCLE_DAYS
            }
        }
    ]
}
EOF

    aws s3api put-bucket-lifecycle-configuration \
        --bucket "$BUCKET_NAME" \
        --lifecycle-configuration file://"$LIFECYCLE_FILE"

    rm -f "$LIFECYCLE_FILE"

    echo
    echo -e "${GREEN}S3 lifecycle policy applied successfully.${NC}"

    log "S3 lifecycle policy configured: $S3_LIFECYCLE_DAYS days"
}