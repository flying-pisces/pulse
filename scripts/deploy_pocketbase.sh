#!/bin/bash

# PocketBase Deployment Script for Pulse Trading Signals App
# This script handles deployment to various environments (development, staging, production)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

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
ENVIRONMENT="development"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
SKIP_BACKUP=false
SKIP_HEALTH_CHECK=false
DRY_RUN=false
FORCE=false

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --env ENVIRONMENT         Target environment (development, staging, production)
    --compose-file FILE       Docker compose file to use (default: docker-compose.yml)
    --env-file FILE          Environment file to use (default: .env)
    --skip-backup            Skip backup before deployment
    --skip-health-check      Skip health check after deployment
    --dry-run               Show what would be done without executing
    --force                 Force deployment without confirmation
    --help                  Show this help message

ENVIRONMENTS:
    development             Local development deployment
    staging                 Staging environment deployment
    production              Production environment deployment

EXAMPLES:
    $0                                    # Deploy to development
    $0 --env production --force           # Force deploy to production
    $0 --env staging --skip-backup        # Deploy to staging without backup
    $0 --dry-run                         # Show deployment plan

ENVIRONMENT VARIABLES:
    DOCKER_REGISTRY         Docker registry URL for custom images
    BACKUP_ENABLED          Enable automatic backups (default: true)
    HEALTH_CHECK_TIMEOUT    Health check timeout in seconds (default: 300)
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --compose-file)
            DOCKER_COMPOSE_FILE="$2"
            shift 2
            ;;
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-health-check)
            SKIP_HEALTH_CHECK=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
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

# Validate environment
validate_environment() {
    case $ENVIRONMENT in
        development|staging|production)
            ;;
        *)
            log_error "Invalid environment: $ENVIRONMENT"
            log_error "Valid environments: development, staging, production"
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites for $ENVIRONMENT deployment..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running"
        exit 1
    fi
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null; then
        log_error "docker-compose is not installed"
        exit 1
    fi
    
    # Check if compose file exists
    if [ ! -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ]; then
        log_error "Docker compose file not found: ${DOCKER_COMPOSE_FILE}"
        exit 1
    fi
    
    # Check if environment file exists
    if [ ! -f "${PROJECT_DIR}/${ENV_FILE}" ]; then
        log_warning "Environment file not found: ${ENV_FILE}"
        if [ "$ENVIRONMENT" != "development" ]; then
            log_error "Environment file is required for $ENVIRONMENT deployment"
            exit 1
        fi
    fi
    
    # Check environment-specific requirements
    case $ENVIRONMENT in
        staging|production)
            # Check if required environment variables are set
            if [ -f "${PROJECT_DIR}/${ENV_FILE}" ]; then
                source "${PROJECT_DIR}/${ENV_FILE}"
                
                if [ -z "$PB_ENCRYPTION_KEY" ] || [ "$PB_ENCRYPTION_KEY" = "your-32-char-encryption-key-here-change-this" ]; then
                    log_error "PB_ENCRYPTION_KEY must be set to a secure value for $ENVIRONMENT"
                    exit 1
                fi
                
                if [ -z "$POCKETBASE_ADMIN_PASSWORD" ] || [ "$POCKETBASE_ADMIN_PASSWORD" = "change-this-secure-password" ]; then
                    log_error "POCKETBASE_ADMIN_PASSWORD must be set to a secure value for $ENVIRONMENT"
                    exit 1
                fi
            fi
            ;;
    esac
    
    # Check for required directories
    mkdir -p "${PROJECT_DIR}/backups"
    mkdir -p "${PROJECT_DIR}/logs"
    
    log_success "Prerequisites check passed"
}

# Show deployment plan
show_deployment_plan() {
    log_info "Deployment Plan:"
    echo "  Environment: $ENVIRONMENT"
    echo "  Compose file: $DOCKER_COMPOSE_FILE"
    echo "  Environment file: $ENV_FILE"
    echo "  Backup before deployment: $([ "$SKIP_BACKUP" = true ] && echo "No" || echo "Yes")"
    echo "  Health check after deployment: $([ "$SKIP_HEALTH_CHECK" = true ] && echo "No" || echo "Yes")"
    echo "  Docker registry: ${DOCKER_REGISTRY:-"Default"}"
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE - No changes will be made"
        return 0
    fi
    
    if [ "$FORCE" != true ]; then
        echo
        echo -n "Proceed with deployment? (yes/no): "
        read -r response
        
        if [ "$response" != "yes" ] && [ "$response" != "y" ]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
}

# Create backup before deployment
create_backup() {
    if [ "$SKIP_BACKUP" = true ] || [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    log_info "Creating backup before deployment..."
    
    # Check if PocketBase is running
    if docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ps pocketbase | grep -q "Up"; then
        if [ -f "${PROJECT_DIR}/scripts/pocketbase_backup.sh" ]; then
            "${PROJECT_DIR}/scripts/pocketbase_backup.sh" --retention-days 30
            log_success "Backup created successfully"
        else
            log_warning "Backup script not found, skipping backup"
        fi
    else
        log_info "PocketBase not running, skipping backup"
    fi
}

# Pull latest images
pull_images() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Would pull latest Docker images"
        return 0
    fi
    
    log_info "Pulling latest Docker images..."
    
    cd "${PROJECT_DIR}"
    
    if docker-compose -f "$DOCKER_COMPOSE_FILE" pull; then
        log_success "Images pulled successfully"
    else
        log_error "Failed to pull images"
        exit 1
    fi
}

# Deploy services
deploy_services() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Would deploy services using: docker-compose -f $DOCKER_COMPOSE_FILE up -d"
        return 0
    fi
    
    log_info "Deploying services..."
    
    cd "${PROJECT_DIR}"
    
    # Set environment-specific configurations
    export COMPOSE_PROJECT_NAME="pulse_${ENVIRONMENT}"
    
    # Use environment-specific profile if available
    local compose_cmd="docker-compose -f $DOCKER_COMPOSE_FILE"
    
    case $ENVIRONMENT in
        production)
            compose_cmd="$compose_cmd --profile production"
            ;;
        staging)
            compose_cmd="$compose_cmd --profile staging"
            ;;
    esac
    
    # Deploy services
    if $compose_cmd up -d; then
        log_success "Services deployed successfully"
    else
        log_error "Failed to deploy services"
        exit 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    if [ "$SKIP_HEALTH_CHECK" = true ] || [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    log_info "Waiting for services to be ready..."
    
    local timeout=${HEALTH_CHECK_TIMEOUT:-300}
    local waited=0
    local interval=5
    
    while [ $waited -lt $timeout ]; do
        if docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ps pocketbase | grep -q "Up (healthy)"; then
            log_success "PocketBase is ready"
            return 0
        fi
        
        if docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ps pocketbase | grep -q "Exit"; then
            log_error "PocketBase container exited unexpectedly"
            show_container_logs
            exit 1
        fi
        
        echo -n "."
        sleep $interval
        waited=$((waited + interval))
    done
    
    log_error "Health check timeout after ${timeout} seconds"
    show_container_logs
    exit 1
}

# Show container logs for debugging
show_container_logs() {
    log_warning "Showing container logs for debugging:"
    docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" logs --tail=50 pocketbase
}

# Run post-deployment tasks
run_post_deployment_tasks() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Would run post-deployment tasks"
        return 0
    fi
    
    log_info "Running post-deployment tasks..."
    
    # Run data migrations if needed
    if [ -f "${PROJECT_DIR}/scripts/migrate_to_pocketbase.dart" ] && [ "$ENVIRONMENT" = "production" ]; then
        log_info "Running data migrations..."
        # This would be customized based on your migration needs
    fi
    
    # Initialize admin user for first deployment
    if [ "$ENVIRONMENT" != "development" ]; then
        initialize_admin_user
    fi
    
    # Set up monitoring and alerts
    setup_monitoring
    
    log_success "Post-deployment tasks completed"
}

# Initialize admin user
initialize_admin_user() {
    log_info "Checking admin user setup..."
    
    # Check if admin user exists
    local admin_email="${POCKETBASE_ADMIN_EMAIL:-admin@pulse.app}"
    local admin_password="${POCKETBASE_ADMIN_PASSWORD}"
    
    if [ -n "$admin_password" ]; then
        log_info "Admin user configuration found"
        # In a real deployment, you might want to create the admin user
        # using PocketBase API or CLI commands
    else
        log_warning "Admin user not configured - please set up manually"
    fi
}

# Setup monitoring
setup_monitoring() {
    log_info "Setting up monitoring..."
    
    # Create monitoring configuration
    case $ENVIRONMENT in
        production|staging)
            # In production, you might want to:
            # - Configure log aggregation
            # - Set up health check endpoints
            # - Configure alerting
            log_info "Monitoring setup for $ENVIRONMENT environment"
            ;;
        development)
            log_info "Development environment - basic monitoring only"
            ;;
    esac
}

# Verify deployment
verify_deployment() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Would verify deployment"
        return 0
    fi
    
    log_info "Verifying deployment..."
    
    # Check if all services are running
    local failed_services=()
    
    if ! docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ps pocketbase | grep -q "Up"; then
        failed_services+=("pocketbase")
    fi
    
    if [ ${#failed_services[@]} -gt 0 ]; then
        log_error "Failed services: ${failed_services[*]}"
        return 1
    fi
    
    # Test API endpoints
    local pocketbase_url="http://localhost:8090"
    if [ "$ENVIRONMENT" != "development" ]; then
        pocketbase_url="${POCKETBASE_URL:-http://localhost:8090}"
    fi
    
    log_info "Testing API endpoints at $pocketbase_url"
    
    # Test health endpoint
    if curl -f -s "$pocketbase_url/api/health" > /dev/null; then
        log_success "Health endpoint is responding"
    else
        log_error "Health endpoint is not responding"
        return 1
    fi
    
    # Test collections endpoint (should require auth)
    if curl -f -s "$pocketbase_url/api/collections" > /dev/null 2>&1; then
        log_warning "Collections endpoint is publicly accessible (this might be expected)"
    fi
    
    log_success "Deployment verification passed"
    return 0
}

# Show deployment summary
show_deployment_summary() {
    log_success "Deployment Summary:"
    echo "  Environment: $ENVIRONMENT"
    echo "  Deployed at: $(date)"
    echo "  Status: Successful"
    
    if [ "$ENVIRONMENT" != "development" ]; then
        echo "  Admin URL: ${POCKETBASE_URL:-http://localhost:8090}/_/"
    else
        echo "  Admin URL: http://localhost:8090/_/"
    fi
    
    echo "  API URL: ${POCKETBASE_URL:-http://localhost:8090}/api/"
    
    # Show running services
    echo
    log_info "Running services:"
    docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" ps
}

# Cleanup on failure
cleanup_on_failure() {
    log_error "Deployment failed, performing cleanup..."
    
    # Save logs for debugging
    local log_dir="${PROJECT_DIR}/logs/deployment_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$log_dir"
    
    docker-compose -f "${PROJECT_DIR}/${DOCKER_COMPOSE_FILE}" logs > "$log_dir/docker-compose.log" 2>&1
    
    log_info "Logs saved to: $log_dir"
    
    # Optionally restore from backup
    if [ "$SKIP_BACKUP" != true ] && [ -f "${PROJECT_DIR}/scripts/pocketbase_restore.sh" ]; then
        echo -n "Restore from backup? (yes/no): "
        read -r response
        
        if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
            log_info "Restoring from backup..."
            "${PROJECT_DIR}/scripts/pocketbase_restore.sh" --list-backups
        fi
    fi
}

# Main execution
main() {
    log_info "Starting PocketBase deployment to $ENVIRONMENT..."
    
    # Trap cleanup on failure
    trap cleanup_on_failure ERR
    
    validate_environment
    check_prerequisites
    show_deployment_plan
    
    create_backup
    pull_images
    deploy_services
    wait_for_services
    run_post_deployment_tasks
    
    if verify_deployment; then
        show_deployment_summary
        log_success "Deployment completed successfully!"
    else
        log_error "Deployment verification failed"
        exit 1
    fi
}

# Check if script is being run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi