#!/bin/bash
# shellcheck disable=SC2034

# EC2 Configuration
INSTANCE_NAME="CloudOps-Demo"

# S3 Configuration
BUCKET_NAME="pushkar-cloudops-backup-2026"

# Backup Configuration
BACKUP_SOURCE="backup-data"
BACKUP_DIR="backups"

# Logging Configuration
LOG_FILE="logs/cloudops.log"

#Cleanup Configuration
BACKUP_RETENTION_DAYS=7

# S3 LifeCycle Configuration
S3_LIFECYCLE_DAYS=7
