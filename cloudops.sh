#!/bin/bash

##############################
## Author: Pushkar Narayan  ##
## Date: 2026-08-25         ##
##############################

set -euo pipefail

# Terminal Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


# Get project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Load configuration
source "$SCRIPT_DIR/config.sh"


# Load modules
source "$SCRIPT_DIR/modules/logs.sh"
source "$SCRIPT_DIR/modules/ec2.sh"
source "$SCRIPT_DIR/modules/s3.sh"
source "$SCRIPT_DIR/modules/monitor.sh"
source "$SCRIPT_DIR/modules/cleanup.sh"
source "$SCRIPT_DIR/modules/lifecycle.sh"
source "$SCRIPT_DIR/modules/report.sh"
source "$SCRIPT_DIR/modules/health.sh"
source "$SCRIPT_DIR/modules/config_check.sh"
source "$SCRIPT_DIR/modules/error_handler.sh"

trap 'error_handler "$LINENO" "$BASH_COMMAND"' ERR

########################################
# Check Required Dependencies
########################################

check_dependencies() {

    REQUIRED_COMMANDS=("aws" "tar" "find")

    for COMMAND in "${REQUIRED_COMMANDS[@]}"; do

        if ! command -v "$COMMAND" &> /dev/null; then

            echo -e "${RED}Error: Required command '$COMMAND' is not installed.${NC}"

            exit 1

        fi

    done
}


########################################
# Show Application Banner
########################################

show_banner() {

    echo
    echo "=============================================="
    echo "            CLOUDOPS TOOLKIT"
    echo "       AWS Cloud Operations CLI"
    echo "=============================================="
    echo
}


########################################
# Interactive Menu
########################################

show_menu() {

    while true; do

        clear

        show_banner

        echo "╔════════════════════════════════════════╗"
        echo "║          ☁ CloudOps Toolkit            ║"
        echo "╠════════════════════════════════════════╣"
        echo "║                                        ║"
        echo "║  1. EC2 Status                         ║"
        echo "║  2. Start EC2                          ║"
        echo "║  3. Stop EC2                           ║"
        echo "║  4. Create S3 Backup                   ║"
        echo "║  5. Monitor EC2                        ║"
        echo "║  6. View Logs                          ║"
        echo "║  7. Cleanup                            ║"
        echo "║  8. AWS Resource Report                ║"
        echo "║  9. Health Check                       ║"
        echo "║ 10. Config Check                       ║"
        echo "║ 11. Exit                       ║"
        echo "║                                        ║"
        echo "╚════════════════════════════════════════╝"

        echo

        read -r -p "Select an option [1-11]: " OPTION


        case "$OPTION" in

            1)
                show_status
                ;;

            2)
                start_instance
                ;;

            3)
                stop_instance
                ;;

            4)
                backup_files
                ;;

            5)
                monitor_instance
                ;;

            6)
                show_logs
                ;;

            7)
                cleanup_resources
                ;;

            8)
                generate_report
                ;;

            9)
                health_check
                ;;

            10)
                validate_config
                ;;

            11)
                echo
                echo -e "${BLUE}Exiting CloudOps Toolkit...${NC}"
                exit 0
                ;;

            *)
                echo
                echo -e "${RED}Invalid option. Please choose 1-11.${NC}"
                ;;

        esac

        echo
        read -r -p "Press Enter to continue..."

    done
}


########################################
# Main Program
########################################

# Check dependencies before running
check_dependencies


# If no argument is provided,
# launch interactive menu
if [ "$#" -eq 0 ]; then

    show_menu

    exit 0

fi


########################################
# Command Line Interface
########################################

case "${1:-}" in

    status)
        show_status
        ;;

    start)
        start_instance
        ;;

    stop)
        stop_instance
        ;;

    backup)
        backup_files
        ;;

    logs)
        show_logs
        ;;

    monitor)
        monitor_instance
        ;;

    cleanup)
        cleanup_resources "${2:-}"
        ;;

    lifecycle)
        configure_s3_lifecycle
        ;;

    report)
        generate_report
        ;;

    health)
        health_check
        ;;

    config)
        validate_config
        ;;

    test)
        "$SCRIPT_DIR/tests/test_cloudops.sh"
        ;;    

    help|--help|-h)
        show_banner

        echo "Usage:"
        echo
        echo "  ./cloudops.sh              Open interactive menu"
        echo "  ./cloudops.sh status       Show EC2 status"
        echo "  ./cloudops.sh start        Start EC2 instance"
        echo "  ./cloudops.sh stop         Stop EC2 instance"
        echo "  ./cloudops.sh backup       Create S3 backup"
        echo "  ./cloudops.sh logs         View activity logs"
        echo "  ./cloudops.sh monitor      Monitor EC2"
        echo "  ./cloudops.sh cleanup      Clean old backups"
        echo "  ./cloudops.sh cleanup --dry-run"
        echo "                             Preview cleanup without deleting files"
        echo "  ./cloudops.sh lifecycle    Configure S3 lifecycle"
        echo "  ./cloudops.sh report       Generate AWS resource report"
        echo "  ./cloudops.sh health       Run CloudOps health check"
        echo "  ./cloudops.sh config       Validate configuration"
        echo "  ./cloudops.sh test         Run automated tests"
        echo "  ./cloudops.sh help         Show this help"
        
        echo
        ;;

    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo
        echo "Run './cloudops.sh help' for usage information."
        exit 1
        ;;

esac