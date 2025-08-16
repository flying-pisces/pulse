#!/bin/bash

# PocketBase Restore Script
# This script restores PocketBase data from backups

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
CONTAINER_NAME="pulse_pocketbase"
BACKUP_PATH=""
FORCE=false
FROM_S3=false
S3_BUCKET=""

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] BACKUP_PATH

OPTIONS:
    --container NAME      PocketBase container name (default: pulse_pocketbase)
    --force              Force restore without confirmation
    --from-s3 BUCKET     Download backup from S3 bucket
    --list-backups       List available backups
    --help               Show this help message

ARGUMENTS:
    BACKUP_PATH          Path to backup file or directory
                        (use backup name when --from-s3 is specified)

EXAMPLES:
    $0 backup_20231201_120000.tar.gz          # Restore from local file
    $0 --from-s3 my-bucket backup_name        # Restore from S3
    $0 --list-backups                         # List available backups
    $0 --force backup.tar.gz                  # Force restore without confirmation

ENVIRONMENT VARIABLES:
    AWS_ACCESS_KEY_ID     AWS access key for S3 download
    AWS_SECRET_ACCESS_KEY AWS secret key for S3 download
    AWS_DEFAULT_REGION    AWS region for S3 bucket
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --from-s3)
            FROM_S3=true
            S3_BUCKET="$2"
            shift 2
            ;;
        --list-backups)
            list_backups
            exit 0
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            BACKUP_PATH="$1"
            shift
            ;;
    esac
done

# List available backups
list_backups() {
    log_info "Available local backups:"
    
    if [ -d "${BACKUP_DIR}" ]; then
        local count=0
        for backup in "${BACKUP_DIR}"/pulse_pocketbase_backup_*; do
            if [ -e "$backup" ]; then
                local name=$(basename "$backup")
                local size
                if [ -f "$backup" ]; then
                    size=$(du -h "$backup" | cut -f1)
                else
                    size=$(du -sh "$backup" | cut -f1)
                fi
                local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null || echo "Unknown")
                echo "  - $name (${size}, ${date})"
                ((count++))
            fi
        done
        
        if [ $count -eq 0 ]; then
            echo "  No local backups found"
        fi
    else
        echo "  Backup directory not found: ${BACKUP_DIR}"
    fi
    
    if [ "$FROM_S3" = true ] && [ -n "$S3_BUCKET" ]; then
        log_info "Available S3 backups in bucket '${S3_BUCKET}':"
        if command -v aws &> /dev/null; then
            aws s3 ls "s3://${S3_BUCKET}/pocketbase-backups/" | awk '{print "  - " $4 " (" $3 ", " $1 " " $2 ")"}'
        else
            log_error "AWS CLI not found"
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running"
        exit 1
    fi
    
    # Check if container exists
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_error "Container '${CONTAINER_NAME}' not found"
        exit 1
    fi
    
    # Check AWS CLI if S3 is used
    if [ "$FROM_S3" = true ]; then
        if ! command -v aws &> /dev/null; then
            log_error "AWS CLI is required for S3 operations but not found"
            exit 1
        fi
        
        if [ -z "$S3_BUCKET" ]; then
            log_error "S3 bucket name is required when --from-s3 is used"
            exit 1
        fi
    fi
    
    log_success "Prerequisites check passed"
}

# Validate backup path
validate_backup() {
    if [ -z "$BACKUP_PATH" ]; then
        log_error "Backup path is required"
        show_usage
        exit 1
    fi
    
    if [ "$FROM_S3" = true ]; then
        # For S3, just check if the file exists in the bucket
        local s3_path="s3://${S3_BUCKET}/pocketbase-backups/${BACKUP_PATH}"
        if ! aws s3 ls "$s3_path" > /dev/null 2>&1; then
            log_error "Backup not found in S3: $s3_path"
            exit 1
        fi
    else
        # For local files, check if path exists
        if [ ! -e "$BACKUP_PATH" ]; then
            # Try relative to backup directory
            local full_path="${BACKUP_DIR}/${BACKUP_PATH}"
            if [ -e "$full_path" ]; then
                BACKUP_PATH="$full_path"
            else
                log_error "Backup not found: $BACKUP_PATH"
                exit 1
            fi
        fi
    fi
}

# Download backup from S3
download_from_s3() {
    if [ "$FROM_S3" = false ]; then
        return 0
    fi
    
    log_info "Downloading backup from S3..."
    
    local s3_path="s3://${S3_BUCKET}/pocketbase-backups/${BACKUP_PATH}"
    local local_path="${BACKUP_DIR}/$(basename "$BACKUP_PATH")"
    
    mkdir -p "${BACKUP_DIR}"
    
    if aws s3 cp "$s3_path" "$local_path"; then
        BACKUP_PATH="$local_path"
        log_success "Backup downloaded: $local_path"
    else
        log_error "Failed to download backup from S3"
        exit 1
    fi
}

# Extract backup if compressed
extract_backup() {
    local backup_path="$1"
    local extract_dir=""
    
    if [[ "$backup_path" == *.tar.gz ]] || [[ "$backup_path" == *.tgz ]]; then
        log_info "Extracting compressed backup..."
        
        extract_dir="${backup_path%.*.*}_extracted"
        mkdir -p "$extract_dir"
        
        if tar -xzf "$backup_path" -C "$extract_dir" --strip-components=1; then
            log_success "Backup extracted to: $extract_dir"
            echo "$extract_dir"
        else
            log_error "Failed to extract backup"
            exit 1
        fi
    else
        echo "$backup_path"
    fi
}

# Verify backup contents
verify_backup() {
    local backup_path="$1"
    
    log_info "Verifying backup contents..."
    
    # Check for required files/directories
    if [ ! -d "${backup_path}/pb_data" ]; then
        log_error "Invalid backup: pb_data directory not found"
        exit 1
    fi
    
    if [ ! -f "${backup_path}/metadata.json" ]; then
        log_warning "Backup metadata not found"
    else
        log_info "Backup metadata:"
        cat "${backup_path}/metadata.json" | jq '.' 2>/dev/null || cat "${backup_path}/metadata.json"
    fi
    
    log_success "Backup verification passed"
}

# Confirm restore operation
confirm_restore() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    log_warning "This operation will replace all current PocketBase data!"
    log_warning "Container: $CONTAINER_NAME"
    log_warning "Backup: $BACKUP_PATH"
    
    echo -n "Are you sure you want to continue? (yes/no): "
    read -r response
    
    if [ "$response" != "yes" ] && [ "$response" != "y" ]; then
        log_info "Restore operation cancelled"
        exit 0
    fi
}

# Create backup of current data before restore
backup_current_data() {
    log_info "Creating backup of current data before restore..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="pre_restore_backup_${timestamp}"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    mkdir -p "$backup_path"
    
    # Stop container temporarily
    local was_running=false
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        was_running=true
        docker stop "${CONTAINER_NAME}"
    fi
    
    # Copy current data
    docker cp "${CONTAINER_NAME}:/pb/pb_data" "${backup_path}/"
    
    # Create metadata
    cat > "${backup_path}/metadata.json" << EOF
{
    "backup_name": "${backup_name}",
    "timestamp": "${timestamp}",
    "container_name": "${CONTAINER_NAME}",
    "created_by": "$(whoami)",
    "backup_type": "pre_restore",
    "version": "1.0"
}
EOF
    
    # Restart container if it was running
    if [ "$was_running" = true ]; then
        docker start "${CONTAINER_NAME}"
    fi
    
    log_success "Current data backed up to: ${backup_path}"
}

# Perform restore
perform_restore() {
    local backup_path="$1"
    
    log_info "Starting restore process..."
    
    # Stop container
    local was_running=false
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        was_running=true
        log_info "Stopping PocketBase container..."
        docker stop "${CONTAINER_NAME}"
    fi
    
    # Remove current data
    log_info "Removing current PocketBase data..."
    docker exec "${CONTAINER_NAME}" rm -rf /pb/pb_data/* 2>/dev/null || true
    
    # Copy backup data
    log_info "Restoring backup data..."
    docker cp "${backup_path}/pb_data/." "${CONTAINER_NAME}:/pb/pb_data/"
    
    # Fix permissions
    log_info "Fixing permissions..."
    docker exec "${CONTAINER_NAME}" chown -R pocketbase:pocketbase /pb/pb_data/ 2>/dev/null || true
    
    # Start container
    if [ "$was_running" = true ]; then
        log_info "Starting PocketBase container..."
        docker start "${CONTAINER_NAME}"
        
        # Wait for container to be healthy
        log_info "Waiting for PocketBase to be ready..."
        local retries=30
        while [ $retries -gt 0 ]; do
            if docker exec "${CONTAINER_NAME}" wget --no-verbose --tries=1 --spider http://localhost:8090/api/health > /dev/null 2>&1; then
                break
            fi
            sleep 2
            ((retries--))
        done
        
        if [ $retries -eq 0 ]; then
            log_error "PocketBase health check timeout after restore"
            exit 1
        else
            log_success "PocketBase is ready"
        fi
    fi
    
    log_success "Restore completed successfully!"
}

# Cleanup temporary files
cleanup() {
    if [ -n "$extract_dir" ] && [ -d "$extract_dir" ]; then
        log_info "Cleaning up temporary files..."
        rm -rf "$extract_dir"
    fi
    
    if [ "$FROM_S3" = true ] && [ -f "$BACKUP_PATH" ]; then
        log_info "Removing downloaded backup file..."
        rm -f "$BACKUP_PATH"
    fi
}

# Main execution
main() {
    log_info "Starting PocketBase restore process..."
    
    check_prerequisites
    validate_backup
    download_from_s3
    
    local backup_path
    backup_path=$(extract_backup "$BACKUP_PATH")
    
    verify_backup "$backup_path"
    confirm_restore
    backup_current_data
    perform_restore "$backup_path"
    
    cleanup
    
    log_success "Restore process completed successfully!"
    log_info "PocketBase has been restored from: $BACKUP_PATH"
}

# Trap cleanup on exit
trap cleanup EXIT

# Check if any arguments provided
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Run main function
main "$@"