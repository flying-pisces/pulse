#!/bin/bash

# PocketBase Backup Script
# This script creates backups of PocketBase data and uploads them to cloud storage

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="pulse_pocketbase_backup_${TIMESTAMP}"

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
RETENTION_DAYS=30
COMPRESS=true
UPLOAD_TO_S3=false
S3_BUCKET=""
VERIFY_BACKUP=true

# Load environment variables
if [ -f "${PROJECT_DIR}/.env" ]; then
    source "${PROJECT_DIR}/.env"
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --retention-days)
            RETENTION_DAYS="$2"
            shift 2
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        --s3-bucket)
            UPLOAD_TO_S3=true
            S3_BUCKET="$2"
            shift 2
            ;;
        --no-verify)
            VERIFY_BACKUP=false
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --container NAME        PocketBase container name (default: pulse_pocketbase)
    --retention-days DAYS   Number of days to keep backups (default: 30)
    --no-compress          Don't compress backup files
    --s3-bucket BUCKET     Upload backup to S3 bucket
    --no-verify           Skip backup verification
    --help                Show this help message

EXAMPLES:
    $0                                    # Basic backup
    $0 --retention-days 7                # Keep backups for 7 days
    $0 --s3-bucket my-backup-bucket      # Upload to S3
    $0 --container my_pocketbase         # Use custom container name

ENVIRONMENT VARIABLES:
    AWS_ACCESS_KEY_ID     AWS access key for S3 upload
    AWS_SECRET_ACCESS_KEY AWS secret key for S3 upload
    AWS_DEFAULT_REGION    AWS region for S3 bucket
EOF
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
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_warning "Container '${CONTAINER_NAME}' is not running"
    fi
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Check AWS CLI if S3 upload is enabled
    if [ "$UPLOAD_TO_S3" = true ]; then
        if ! command -v aws &> /dev/null; then
            log_error "AWS CLI is required for S3 upload but not found"
            exit 1
        fi
        
        if [ -z "$S3_BUCKET" ]; then
            log_error "S3 bucket name is required when --s3-bucket is used"
            exit 1
        fi
    fi
    
    log_success "Prerequisites check passed"
}

# Create backup
create_backup() {
    log_info "Creating backup: ${BACKUP_NAME}"
    
    local backup_path="${BACKUP_DIR}/${BACKUP_NAME}"
    mkdir -p "${backup_path}"
    
    # Stop container temporarily for consistent backup
    local was_running=false
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        was_running=true
        log_info "Stopping PocketBase container for backup..."
        docker stop "${CONTAINER_NAME}"
    fi
    
    # Copy pb_data directory
    log_info "Copying PocketBase data..."
    docker cp "${CONTAINER_NAME}:/pb/pb_data" "${backup_path}/"
    
    # Create metadata file
    cat > "${backup_path}/metadata.json" << EOF
{
    "backup_name": "${BACKUP_NAME}",
    "timestamp": "${TIMESTAMP}",
    "container_name": "${CONTAINER_NAME}",
    "created_by": "$(whoami)",
    "hostname": "$(hostname)",
    "backup_type": "full",
    "version": "1.0"
}
EOF
    
    # Copy docker-compose.yml and environment files
    if [ -f "${PROJECT_DIR}/docker-compose.yml" ]; then
        cp "${PROJECT_DIR}/docker-compose.yml" "${backup_path}/"
    fi
    
    if [ -f "${PROJECT_DIR}/.env.pocketbase" ]; then
        cp "${PROJECT_DIR}/.env.pocketbase" "${backup_path}/"
    fi
    
    # Restart container if it was running
    if [ "$was_running" = true ]; then
        log_info "Restarting PocketBase container..."
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
            log_warning "PocketBase health check timeout after restart"
        else
            log_success "PocketBase is ready"
        fi
    fi
    
    log_success "Backup created at: ${backup_path}"
}

# Compress backup
compress_backup() {
    if [ "$COMPRESS" = true ]; then
        log_info "Compressing backup..."
        
        local backup_path="${BACKUP_DIR}/${BACKUP_NAME}"
        local archive_path="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
        
        tar -czf "${archive_path}" -C "${BACKUP_DIR}" "${BACKUP_NAME}"
        
        # Remove uncompressed backup
        rm -rf "${backup_path}"
        
        log_success "Backup compressed: ${archive_path}"
        echo "${archive_path}"
    else
        echo "${BACKUP_DIR}/${BACKUP_NAME}"
    fi
}

# Verify backup
verify_backup() {
    if [ "$VERIFY_BACKUP" = false ]; then
        return 0
    fi
    
    log_info "Verifying backup..."
    
    local backup_path="$1"
    
    if [ "$COMPRESS" = true ]; then
        # Verify compressed archive
        if tar -tzf "${backup_path}" > /dev/null 2>&1; then
            log_success "Backup archive verification passed"
        else
            log_error "Backup archive verification failed"
            return 1
        fi
    else
        # Verify directory structure
        if [ -d "${backup_path}/pb_data" ] && [ -f "${backup_path}/metadata.json" ]; then
            log_success "Backup directory verification passed"
        else
            log_error "Backup directory verification failed"
            return 1
        fi
    fi
    
    return 0
}

# Upload to S3
upload_to_s3() {
    if [ "$UPLOAD_TO_S3" = false ]; then
        return 0
    fi
    
    log_info "Uploading backup to S3..."
    
    local backup_path="$1"
    local filename=$(basename "${backup_path}")
    local s3_path="s3://${S3_BUCKET}/pocketbase-backups/${filename}"
    
    if aws s3 cp "${backup_path}" "${s3_path}"; then
        log_success "Backup uploaded to: ${s3_path}"
    else
        log_error "Failed to upload backup to S3"
        return 1
    fi
    
    return 0
}

# Clean old backups
cleanup_old_backups() {
    log_info "Cleaning up old backups (older than ${RETENTION_DAYS} days)..."
    
    # Local cleanup
    find "${BACKUP_DIR}" -name "pulse_pocketbase_backup_*" -type f -mtime +${RETENTION_DAYS} -delete
    find "${BACKUP_DIR}" -name "pulse_pocketbase_backup_*" -type d -mtime +${RETENTION_DAYS} -exec rm -rf {} +
    
    # S3 cleanup
    if [ "$UPLOAD_TO_S3" = true ]; then
        local cutoff_date=$(date -d "${RETENTION_DAYS} days ago" +%Y-%m-%d)
        aws s3 ls "s3://${S3_BUCKET}/pocketbase-backups/" | while read -r line; do
            local file_date=$(echo "$line" | awk '{print $1}')
            local file_name=$(echo "$line" | awk '{print $4}')
            
            if [[ "$file_date" < "$cutoff_date" ]]; then
                log_info "Deleting old S3 backup: ${file_name}"
                aws s3 rm "s3://${S3_BUCKET}/pocketbase-backups/${file_name}"
            fi
        done
    fi
    
    log_success "Old backups cleaned up"
}

# Main execution
main() {
    log_info "Starting PocketBase backup process..."
    
    check_prerequisites
    create_backup
    
    local backup_path
    backup_path=$(compress_backup)
    
    if verify_backup "${backup_path}"; then
        upload_to_s3 "${backup_path}"
        cleanup_old_backups
        
        log_success "Backup process completed successfully!"
        log_info "Backup location: ${backup_path}"
        
        # Print backup size
        if [ -f "${backup_path}" ]; then
            local size=$(du -h "${backup_path}" | cut -f1)
            log_info "Backup size: ${size}"
        fi
    else
        log_error "Backup verification failed!"
        exit 1
    fi
}

# Run main function
main "$@"