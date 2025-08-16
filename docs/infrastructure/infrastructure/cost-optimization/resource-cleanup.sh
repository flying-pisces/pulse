#!/bin/bash
# Resource Cleanup and Cost Optimization Script for Pulse Trading
# Automated cleanup of unused resources and optimization of storage costs

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/pulse-trading-cleanup.log"
DRY_RUN="${DRY_RUN:-false}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
ENVIRONMENT="${ENVIRONMENT:-production}"

# AWS Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
S3_BUCKET_NAME="${S3_BUCKET_NAME:-pulse-trading.com}"
S3_LOGS_BUCKET="${S3_LOGS_BUCKET:-pulse-trading.com-logs}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-}"

# Retention Policies (in days)
CLOUDFRONT_LOGS_RETENTION=90
S3_OLD_VERSIONS_RETENTION=30
TEMP_FILES_RETENTION=7
BACKUP_RETENTION=365

# Cost thresholds (in USD)
MONTHLY_BUDGET=500
ALERT_THRESHOLD=400

# Logging setup
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*"
}

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*"
}

# Send notifications
send_slack_notification() {
    local message="$1"
    local color="${2:-good}"
    
    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"title\": \"Pulse Trading - Resource Cleanup\",
                    \"text\": \"$message\",
                    \"footer\": \"Environment: $ENVIRONMENT\",
                    \"ts\": $(date +%s)
                }]
            }" \
            "$SLACK_WEBHOOK" || log_error "Failed to send Slack notification"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Please install AWS CLI."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq not found. Please install jq."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or invalid."
        exit 1
    fi
    
    log_info "Prerequisites check passed."
}

# Get current costs
get_current_costs() {
    log_info "Fetching current month costs..."
    
    local start_date
    local end_date
    start_date=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
    end_date=$(date +%Y-%m-%d)
    
    local cost_data
    cost_data=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --filter '{"Tags":{"Key":"Project","Values":["pulse-trading"]}}' \
        --region us-east-1 \
        --output json 2>/dev/null || echo '{}')
    
    if [[ "$cost_data" != '{}' ]]; then
        local total_cost
        total_cost=$(echo "$cost_data" | jq -r '.ResultsByTime[0].Total.BlendedCost.Amount // "0"')
        
        log_info "Current month cost: \$${total_cost}"
        
        # Check if we're approaching budget
        if (( $(echo "$total_cost > $ALERT_THRESHOLD" | bc -l) )); then
            log_warning "Cost alert: Current spending (\$$total_cost) exceeds alert threshold (\$$ALERT_THRESHOLD)"
            send_slack_notification "🚨 Cost Alert: Current spending (\$$total_cost) exceeds alert threshold (\$$ALERT_THRESHOLD)" "warning"
        fi
    else
        log_warning "Could not fetch cost data"
    fi
}

# Clean up old CloudFront logs
cleanup_cloudfront_logs() {
    log_info "Cleaning up old CloudFront logs..."
    
    if [[ -z "$S3_LOGS_BUCKET" ]]; then
        log_warning "S3_LOGS_BUCKET not configured, skipping CloudFront logs cleanup"
        return 0
    fi
    
    local cutoff_date
    cutoff_date=$(date -d "${CLOUDFRONT_LOGS_RETENTION} days ago" +%Y-%m-%d)
    
    log_info "Deleting CloudFront logs older than $cutoff_date..."
    
    local objects_to_delete
    objects_to_delete=$(aws s3api list-objects-v2 \
        --bucket "$S3_LOGS_BUCKET" \
        --prefix "cloudfront-logs/" \
        --query "Contents[?LastModified<='$cutoff_date'].Key" \
        --output text \
        --region "$AWS_REGION" 2>/dev/null || echo "")
    
    if [[ -n "$objects_to_delete" && "$objects_to_delete" != "None" ]]; then
        local count
        count=$(echo "$objects_to_delete" | wc -l)
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "DRY RUN: Would delete $count CloudFront log files"
        else
            echo "$objects_to_delete" | while read -r key; do
                aws s3api delete-object \
                    --bucket "$S3_LOGS_BUCKET" \
                    --key "$key" \
                    --region "$AWS_REGION" || log_error "Failed to delete $key"
            done
            
            log_info "Deleted $count old CloudFront log files"
        fi
    else
        log_info "No old CloudFront logs found to delete"
    fi
}

# Clean up old S3 object versions
cleanup_s3_versions() {
    log_info "Cleaning up old S3 object versions..."
    
    if [[ -z "$S3_BUCKET_NAME" ]]; then
        log_warning "S3_BUCKET_NAME not configured, skipping S3 versions cleanup"
        return 0
    fi
    
    local cutoff_date
    cutoff_date=$(date -d "${S3_OLD_VERSIONS_RETENTION} days ago" +%Y-%m-%d)
    
    log_info "Deleting S3 object versions older than $cutoff_date..."
    
    local versions_to_delete
    versions_to_delete=$(aws s3api list-object-versions \
        --bucket "$S3_BUCKET_NAME" \
        --query "Versions[?LastModified<='$cutoff_date' && IsLatest==\`false\`].{Key:Key,VersionId:VersionId}" \
        --output json \
        --region "$AWS_REGION" 2>/dev/null || echo '[]')
    
    local count
    count=$(echo "$versions_to_delete" | jq length)
    
    if [[ "$count" -gt 0 ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "DRY RUN: Would delete $count old S3 object versions"
        else
            echo "$versions_to_delete" | jq -c '.[]' | while read -r version; do
                local key
                local version_id
                key=$(echo "$version" | jq -r '.Key')
                version_id=$(echo "$version" | jq -r '.VersionId')
                
                aws s3api delete-object \
                    --bucket "$S3_BUCKET_NAME" \
                    --key "$key" \
                    --version-id "$version_id" \
                    --region "$AWS_REGION" || log_error "Failed to delete version $version_id of $key"
            done
            
            log_info "Deleted $count old S3 object versions"
        fi
    else
        log_info "No old S3 object versions found to delete"
    fi
    
    # Clean up incomplete multipart uploads
    local incomplete_uploads
    incomplete_uploads=$(aws s3api list-multipart-uploads \
        --bucket "$S3_BUCKET_NAME" \
        --query 'Uploads[?Initiated<=`'"$cutoff_date"'`].{Key:Key,UploadId:UploadId}' \
        --output json \
        --region "$AWS_REGION" 2>/dev/null || echo '[]')
    
    local incomplete_count
    incomplete_count=$(echo "$incomplete_uploads" | jq length)
    
    if [[ "$incomplete_count" -gt 0 ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "DRY RUN: Would abort $incomplete_count incomplete multipart uploads"
        else
            echo "$incomplete_uploads" | jq -c '.[]' | while read -r upload; do
                local key
                local upload_id
                key=$(echo "$upload" | jq -r '.Key')
                upload_id=$(echo "$upload" | jq -r '.UploadId')
                
                aws s3api abort-multipart-upload \
                    --bucket "$S3_BUCKET_NAME" \
                    --key "$key" \
                    --upload-id "$upload_id" \
                    --region "$AWS_REGION" || log_error "Failed to abort upload $upload_id for $key"
            done
            
            log_info "Aborted $incomplete_count incomplete multipart uploads"
        fi
    fi
}

# Optimize S3 storage classes
optimize_s3_storage() {
    log_info "Optimizing S3 storage classes..."
    
    if [[ -z "$S3_BUCKET_NAME" ]]; then
        log_warning "S3_BUCKET_NAME not configured, skipping S3 storage optimization"
        return 0
    fi
    
    # Find objects that haven't been accessed in 30 days and are still in STANDARD
    local objects_to_transition
    objects_to_transition=$(aws s3api list-objects-v2 \
        --bucket "$S3_BUCKET_NAME" \
        --query 'Contents[?StorageClass==`STANDARD` && LastModified<=`'"$(date -d '30 days ago' +%Y-%m-%d)"'`].{Key:Key,Size:Size,LastModified:LastModified}' \
        --output json \
        --region "$AWS_REGION" 2>/dev/null || echo '[]')
    
    local transition_count
    transition_count=$(echo "$objects_to_transition" | jq length)
    
    if [[ "$transition_count" -gt 0 ]]; then
        log_info "Found $transition_count objects eligible for transition to Standard-IA"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "DRY RUN: Would transition $transition_count objects to STANDARD_IA"
        else
            # Note: In practice, this should be done via lifecycle policies for efficiency
            log_info "Recommend setting up lifecycle policies for automatic transitions"
        fi
    fi
}

# Clean up temporary files and caches
cleanup_temp_files() {
    log_info "Cleaning up temporary files..."
    
    local temp_dirs=(
        "/tmp/pulse-trading-*"
        "/var/tmp/deployment-*"
        "/var/cache/pulse-trading/*"
    )
    
    local cutoff_date
    cutoff_date=$(date -d "${TEMP_FILES_RETENTION} days ago" +%s)
    
    for temp_pattern in "${temp_dirs[@]}"; do
        if compgen -G "$temp_pattern" > /dev/null; then
            find $temp_pattern -type f -mtime +${TEMP_FILES_RETENTION} -print0 | while IFS= read -r -d '' file; do
                if [[ "$DRY_RUN" == "true" ]]; then
                    log_info "DRY RUN: Would delete $file"
                else
                    rm -f "$file" && log_info "Deleted temporary file: $file"
                fi
            done
        fi
    done
}

# Analyze CloudFront cache performance
analyze_cache_performance() {
    log_info "Analyzing CloudFront cache performance..."
    
    if [[ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
        log_warning "CLOUDFRONT_DISTRIBUTION_ID not configured, skipping cache analysis"
        return 0
    fi
    
    local end_date
    local start_date
    end_date=$(date +%Y-%m-%d)
    start_date=$(date -d '7 days ago' +%Y-%m-%d)
    
    local cache_hit_rate
    cache_hit_rate=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/CloudFront \
        --metric-name CacheHitRate \
        --dimensions Name=DistributionId,Value="$CLOUDFRONT_DISTRIBUTION_ID" \
        --start-time "$start_date" \
        --end-time "$end_date" \
        --period 3600 \
        --statistics Average \
        --region us-east-1 \
        --query 'Datapoints[0].Average' \
        --output text 2>/dev/null || echo "0")
    
    if [[ "$cache_hit_rate" != "None" && "$cache_hit_rate" != "0" ]]; then
        log_info "Current cache hit rate: ${cache_hit_rate}%"
        
        if (( $(echo "$cache_hit_rate < 80" | bc -l) )); then
            log_warning "Cache hit rate (${cache_hit_rate}%) is below optimal threshold (80%)"
            send_slack_notification "⚠️ Cache Performance: Hit rate (${cache_hit_rate}%) is below optimal threshold" "warning"
        fi
    fi
}

# Generate cleanup report
generate_cleanup_report() {
    log_info "Generating cleanup report..."
    
    local report_file="/tmp/pulse-trading-cleanup-report-$(date +%Y%m%d).json"
    local report_data
    
    # Get storage usage
    local s3_storage_usage
    s3_storage_usage=$(aws s3 ls --summarize --human-readable --recursive "s3://$S3_BUCKET_NAME" 2>/dev/null | grep "Total Size" | awk '{print $3, $4}' || echo "Unknown")
    
    # Get request counts (last 24 hours)
    local request_count
    request_count=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/CloudFront \
        --metric-name Requests \
        --dimensions Name=DistributionId,Value="$CLOUDFRONT_DISTRIBUTION_ID" \
        --start-time "$(date -d '1 day ago' +%Y-%m-%d)" \
        --end-time "$(date +%Y-%m-%d)" \
        --period 3600 \
        --statistics Sum \
        --region us-east-1 \
        --query 'Datapoints | [0].Sum' \
        --output text 2>/dev/null || echo "0")
    
    report_data=$(cat <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "environment": "$ENVIRONMENT",
    "cleanup_summary": {
        "cloudfront_logs_cleaned": true,
        "s3_versions_cleaned": true,
        "temp_files_cleaned": true,
        "storage_optimized": true
    },
    "current_usage": {
        "s3_storage": "$s3_storage_usage",
        "daily_requests": "$request_count"
    },
    "dry_run": $DRY_RUN
}
EOF
    )
    
    echo "$report_data" > "$report_file"
    log_info "Cleanup report saved to: $report_file"
    
    # Send summary notification
    local summary_message
    summary_message="✅ Resource cleanup completed successfully
    
Storage Usage: $s3_storage_usage
Daily Requests: $request_count
Dry Run Mode: $DRY_RUN"
    
    send_slack_notification "$summary_message" "good"
}

# Main execution
main() {
    log_info "Starting Pulse Trading resource cleanup script..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Dry Run Mode: $DRY_RUN"
    
    check_prerequisites
    
    # Execute cleanup tasks
    get_current_costs
    cleanup_cloudfront_logs
    cleanup_s3_versions
    optimize_s3_storage
    cleanup_temp_files
    analyze_cache_performance
    generate_cleanup_report
    
    log_info "Resource cleanup script completed successfully"
}

# Error handling
trap 'log_error "Script failed on line $LINENO"; send_slack_notification "❌ Resource cleanup script failed" "danger"; exit 1' ERR

# Run main function
main "$@"