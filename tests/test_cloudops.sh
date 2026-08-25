#!/bin/bash

##############################
## Author: Pushkar Narayan  ##
## Date: 2026-08-25         ##
##############################

########################################
# CloudOps Toolkit Test Suite
########################################

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS_COUNT=0
FAIL_COUNT=0


########################################
# Colors
########################################

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


########################################
# Test Function
########################################

run_test() {

    local TEST_NAME="$1"
    local COMMAND="$2"

    if eval "$COMMAND" &> /dev/null; then

        echo -e "[${GREEN}PASS${NC}] $TEST_NAME"

        ((PASS_COUNT++))

    else

        echo -e "[${RED}FAIL${NC}] $TEST_NAME"

        ((FAIL_COUNT++))

    fi
}


########################################
# Header
########################################

echo
echo "========================================"
echo "       CLOUDOPS TEST SUITE"
echo "========================================"
echo


########################################
# Project Structure Tests
########################################

run_test \
    "cloudops.sh exists" \
    "[ -f '$SCRIPT_DIR/cloudops.sh' ]"


run_test \
    "cloudops.sh executable" \
    "[ -x '$SCRIPT_DIR/cloudops.sh' ]"


run_test \
    "config.sh exists" \
    "[ -f '$SCRIPT_DIR/config.sh' ]"


run_test \
    "modules directory exists" \
    "[ -d '$SCRIPT_DIR/modules' ]"


run_test \
    "tests directory exists" \
    "[ -d '$SCRIPT_DIR/tests' ]"


run_test \
    "backup directory exists" \
    "[ -d '$SCRIPT_DIR/backups' ]"


run_test \
    "logs directory exists" \
    "[ -d '$SCRIPT_DIR/logs' ]"


run_test \
    "reports directory exists" \
    "[ -d '$SCRIPT_DIR/reports' ]"


########################################
# Module Tests
########################################

run_test \
    "EC2 module exists" \
    "[ -f '$SCRIPT_DIR/modules/ec2.sh' ]"


run_test \
    "S3 module exists" \
    "[ -f '$SCRIPT_DIR/modules/s3.sh' ]"


run_test \
    "Logging module exists" \
    "[ -f '$SCRIPT_DIR/modules/logs.sh' ]"


run_test \
    "Monitoring module exists" \
    "[ -f '$SCRIPT_DIR/modules/monitor.sh' ]"


run_test \
    "Cleanup module exists" \
    "[ -f '$SCRIPT_DIR/modules/cleanup.sh' ]"


run_test \
    "Lifecycle module exists" \
    "[ -f '$SCRIPT_DIR/modules/lifecycle.sh' ]"


run_test \
    "Report module exists" \
    "[ -f '$SCRIPT_DIR/modules/report.sh' ]"


run_test \
    "Health module exists" \
    "[ -f '$SCRIPT_DIR/modules/health.sh' ]"


run_test \
    "Config validation module exists" \
    "[ -f '$SCRIPT_DIR/modules/config_check.sh' ]"


run_test \
    "Error handler exists" \
    "[ -f '$SCRIPT_DIR/modules/error_handler.sh' ]"


########################################
# Dependency Tests
########################################

run_test \
    "AWS CLI available" \
    "command -v aws"


run_test \
    "tar available" \
    "command -v tar"


run_test \
    "find available" \
    "command -v find"


run_test \
    "bc available" \
    "command -v bc"


########################################
# Script Syntax Tests
########################################

run_test \
    "cloudops.sh syntax valid" \
    "bash -n '$SCRIPT_DIR/cloudops.sh'"


run_test \
    "config.sh syntax valid" \
    "bash -n '$SCRIPT_DIR/config.sh'"


########################################
# Module Syntax Tests
########################################

for MODULE in "$SCRIPT_DIR"/modules/*.sh; do

    MODULE_NAME=$(basename "$MODULE")

    run_test \
        "$MODULE_NAME syntax valid" \
        "bash -n '$MODULE'"

done


########################################
# CLI Tests
########################################

run_test \
    "help command works" \
    "'$SCRIPT_DIR/cloudops.sh' help"

########################################
# Dry Run Test
########################################

run_test \
    "cleanup dry-run works" \
    "'$SCRIPT_DIR/cloudops.sh' cleanup --dry-run"

########################################
# Test Summary
########################################

echo
echo "========================================"
echo "             TEST SUMMARY"
echo "========================================"

echo
echo "Tests Passed : $PASS_COUNT"
echo "Tests Failed : $FAIL_COUNT"

echo

if [ "$FAIL_COUNT" -eq 0 ]; then

    echo -e "RESULT: ${GREEN}PASS${NC}"

    echo "========================================"

    exit 0

else

    echo -e "RESULT: ${RED}FAIL${NC}"

    echo "========================================"

    exit 1

fi