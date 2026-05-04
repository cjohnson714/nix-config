#!/usr/bin/env bash
# NixOS Configuration Deployment Script
# Automates deployment, testing, and maintenance of NixOS configurations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOST="${1:-}"
FLAKE_HOST="${2:-}"
ACTION="${3:-deploy}"

# Logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Help function
show_help() {
    cat << EOF
NixOS Configuration Deployment Script

Usage: $0 <hostname> [flake-host] [action]

Arguments:
  hostname     Target hostname (e.g., athena, nixos-vm)
  flake-host   Flake hostname (optional, defaults to hostname)
  action       Action to perform (deploy, test, rollback, update, status)

Actions:
  deploy       Deploy configuration (default)
  test         Test configuration without applying
  rollback     Rollback to previous generation
  update       Update flake and deploy
  status       Show system status
  health       Run health checks

Examples:
  $0 athena                    # Deploy to athena
  $0 athena athena test        # Test athena configuration
  $0 nixos-vm nixos-vm update # Update and deploy to nixos-vm
  $0 athena athena rollback   # Rollback athena

Environment Variables:
  NIX_PATH          Custom NIX_PATH
  NIX_CONFIG        Custom NIX_CONFIG
  DEPLOY_TIMEOUT    Deployment timeout in seconds (default: 300)
  SKIP_TESTS        Skip tests (true/false, default: false)
  BACKUP_CONFIG     Backup configuration before deploy (default: true)

EOF
}

# Validate inputs
validate_inputs() {
    if [[ -z "$HOST" ]]; then
        error "Hostname is required"
        show_help
        exit 1
    fi
    
    # Check if host configuration exists
    if [[ ! -d "$REPO_ROOT/hosts/$HOST" ]]; then
        error "Host configuration not found: $HOST"
        exit 1
    fi
    
    # Set default flake host
    if [[ -z "$FLAKE_HOST" ]]; then
        FLAKE_HOST="$HOST"
    fi
    
    log "Target host: $HOST"
    log "Flake host: $FLAKE_HOST"
    log "Action: $ACTION"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if we're in NixOS
    if [[ ! -f /etc/nixos/configuration.nix ]]; then
        warning "Not running on NixOS, some features may be limited"
    fi
    
    # Check if flake exists
    if [[ ! -f "$REPO_ROOT/flake.nix" ]]; then
        error "Flake not found: $REPO_ROOT/flake.nix"
        exit 1
    fi
    
    # Check if nix command is available
    if ! command -v nix &> /dev/null; then
        error "nix command not found"
        exit 1
    fi
    
    # Check if we have write permissions
    if [[ ! -w "$REPO_ROOT" ]]; then
        error "No write permissions to repository"
        exit 1
    fi
    
    success "Prerequisites check passed"
}

# Backup current configuration
backup_config() {
    if [[ "${BACKUP_CONFIG:-true}" == "true" ]]; then
        log "Backing up current configuration..."
        
        local backup_dir="$REPO_ROOT/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Backup current system configuration
        if [[ -f /etc/nixos/configuration.nix ]]; then
            sudo cp -r /etc/nixos "$backup_dir/"
        fi
        
        # Backup current flake
        cp -r "$REPO_ROOT" "$backup_dir/repo"
        
        success "Configuration backed up to: $backup_dir"
    fi
}

# Run tests
run_tests() {
    if [[ "${SKIP_TESTS:-false}" == "true" ]]; then
        warning "Skipping tests"
        return 0
    fi
    
    log "Running tests..."
    
    cd "$REPO_ROOT"
    
    # Run basic tests
    log "Running basic structure tests..."
    if ! python test-config.nix; then
        error "Basic tests failed"
        return 1
    fi
    
    # Run advanced tests
    log "Running advanced tests..."
    if ! python test-advanced.py; then
        warning "Advanced tests had warnings"
    fi
    
    # Run window manager tests
    log "Running window manager tests..."
    if ! python test-window-managers.py; then
        warning "Window manager tests had warnings"
    fi
    
    # Run security tests
    log "Running security tests..."
    if ! python test-security.py; then
        warning "Security tests had warnings"
    fi
    
    success "All tests completed"
}

# Validate configuration
validate_config() {
    log "Validating configuration..."
    
    cd "$REPO_ROOT"
    
    # Check flake
    if ! nix flake check; then
        error "Flake check failed"
        return 1
    fi
    
    # Validate host configuration
    if ! nix eval ".#nixosConfigurations.$FLAKE_HOST.config.system.build.toplevel.drvPath"; then
        error "Host configuration validation failed"
        return 1
    fi
    
    success "Configuration validation passed"
}

# Build configuration
build_config() {
    log "Building configuration for $FLAKE_HOST..."
    
    cd "$REPO_ROOT"
    
    local build_cmd="nix build .#nixosConfigurations.$FLAKE_HOST.config.system.build.toplevel"
    local timeout="${DEPLOY_TIMEOUT:-300}"
    
    # Run build with timeout
    if timeout "$timeout" bash -c "$build_cmd"; then
        success "Configuration built successfully"
    else
        error "Build failed or timed out"
        return 1
    fi
}

# Deploy configuration
deploy_config() {
    log "Deploying configuration to $HOST..."
    
    cd "$REPO_ROOT"
    
    # Check if we're deploying to local system
    if [[ "$(hostname)" == "$HOST" ]]; then
        log "Deploying to local system..."
        
        if sudo nixos-rebuild switch --flake ".#$FLAKE_HOST"; then
            success "Configuration deployed successfully"
        else
            error "Deployment failed"
            return 1
        fi
    else
        log "Remote deployment not implemented yet"
        error "Remote deployment requires additional setup"
        return 1
    fi
}

# Test configuration
test_config() {
    log "Testing configuration for $FLAKE_HOST..."
    
    cd "$REPO_ROOT"
    
    # Run tests
    run_tests || return 1
    
    # Validate configuration
    validate_config || return 1
    
    # Build configuration
    build_config || return 1
    
    success "Configuration test completed successfully"
}

# Rollback configuration
rollback_config() {
    log "Rolling back configuration on $HOST..."
    
    if [[ "$(hostname)" == "$HOST" ]]; then
        if sudo nixos-rebuild switch --rollback; then
            success "Configuration rolled back successfully"
        else
            error "Rollback failed"
            return 1
        fi
    else
        error "Remote rollback not implemented"
        return 1
    fi
}

# Update and deploy
update_and_deploy() {
    log "Updating flake and deploying..."
    
    cd "$REPO_ROOT"
    
    # Update flake inputs
    log "Updating flake inputs..."
    if ! nix flake update; then
        error "Flake update failed"
        return 1
    fi
    
    # Run tests
    run_tests || return 1
    
    # Validate configuration
    validate_config || return 1
    
    # Build and deploy
    build_config || return 1
    deploy_config || return 1
    
    success "Update and deployment completed"
}

# Show system status
show_status() {
    log "System status for $HOST..."
    
    if [[ "$(hostname)" == "$HOST" ]]; then
        # Show current generation
        echo "Current generation:"
        nix-env --list-generations --profile /nix/var/nix/profiles/system | head -5
        
        # Show boot status
        echo ""
        echo "Boot status:"
        sudo bootctl status
        
        # Show service status
        echo ""
        echo "Failed services:"
        systemctl --failed
        
        # Show disk usage
        echo ""
        echo "Disk usage:"
        df -h
        
        success "Status report completed"
    else
        error "Remote status not implemented"
        return 1
    fi
}

# Run health checks
run_health_checks() {
    log "Running health checks..."
    
    cd "$REPO_ROOT"
    
    # Run all tests
    run_tests
    
    # Check system health
    if [[ "$(hostname)" == "$HOST" ]]; then
        log "Checking system health..."
        
        # Check disk space
        local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [[ $disk_usage -gt 80 ]]; then
            warning "Disk usage is ${disk_usage}%"
        fi
        
        # Check memory usage
        local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [[ $mem_usage -gt 90 ]]; then
            warning "Memory usage is ${mem_usage}%"
        fi
        
        # Check load average
        local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        if (( $(echo "$load_avg > 2.0" | bc -l) )); then
            warning "Load average is $load_avg"
        fi
        
        # Check failed services
        local failed_services=$(systemctl --failed --no-legend | wc -l)
        if [[ $failed_services -gt 0 ]]; then
            warning "$failed_services failed services"
        fi
    fi
    
    success "Health checks completed"
}

# Cleanup old generations
cleanup_generations() {
    log "Cleaning up old generations..."
    
    if [[ "$(hostname)" == "$HOST" ]]; then
        # Keep last 5 generations
        sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
        
        # Garbage collect
        sudo nix-collect-garbage -d
        
        success "Cleanup completed"
    else
        error "Remote cleanup not implemented"
        return 1
    fi
}

# Main execution
main() {
    log "Starting NixOS Configuration Deployment"
    log "Repository: $REPO_ROOT"
    
    # Show help if requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Validate inputs
    validate_inputs
    
    # Check prerequisites
    check_prerequisites
    
    # Change to repository root
    cd "$REPO_ROOT"
    
    # Execute action
    case "$ACTION" in
        "deploy")
            backup_config
            run_tests || exit 1
            validate_config || exit 1
            build_config || exit 1
            deploy_config || exit 1
            ;;
        "test")
            test_config || exit 1
            ;;
        "rollback")
            rollback_config || exit 1
            ;;
        "update")
            update_and_deploy || exit 1
            ;;
        "status")
            show_status
            ;;
        "health")
            run_health_checks
            ;;
        "cleanup")
            cleanup_generations
            ;;
        *)
            error "Unknown action: $ACTION"
            show_help
            exit 1
            ;;
    esac
    
    success "Deployment script completed successfully"
}

# Trap for cleanup
trap 'error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
