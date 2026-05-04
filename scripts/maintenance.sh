#!/usr/bin/env bash
# NixOS Configuration Maintenance Script
# Provides automated maintenance tasks for NixOS configurations

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
LOG_FILE="$REPO_ROOT/logs/maintenance.log"
BACKUP_DIR="$REPO_ROOT/backups"

# Logging
log() {
    local message="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${BLUE}$message${NC}"
    echo "$message" >> "$LOG_FILE"
}

success() {
    local message="[SUCCESS] $1"
    echo -e "${GREEN}$message${NC}"
    echo "$message" >> "$LOG_FILE"
}

warning() {
    local message="[WARNING] $1"
    echo -e "${YELLOW}$message${NC}"
    echo "$message" >> "$LOG_FILE"
}

error() {
    local message="[ERROR] $1"
    echo -e "${RED}$message${NC}"
    echo "$message" >> "$LOG_FILE"
}

# Create directories
setup_directories() {
    mkdir -p "$REPO_ROOT/logs" "$BACKUP_DIR"
}

# Help function
show_help() {
    cat << EOF
NixOS Configuration Maintenance Script

Usage: $0 <task> [options]

Tasks:
  cleanup       Clean up old generations and store
  backup        Backup configuration and system state
  update        Update flake inputs and dependencies
  validate      Validate all configurations
  analyze       Analyze configuration performance
  report        Generate maintenance report
  health        Run comprehensive health checks
  optimize      Optimize nix store and configurations
  monitor       Start monitoring daemon
  all           Run all maintenance tasks

Options:
  --dry-run     Show what would be done without executing
  --verbose     Enable verbose output
  --force       Skip confirmation prompts

Examples:
  $0 cleanup                    # Clean up old generations
  $0 backup --dry-run           # Show backup plan
  $0 all --verbose              # Run all tasks with verbose output
  $0 health --force             # Run health checks without prompts

EOF
}

# Parse command line arguments
DRY_RUN=false
VERBOSE=false
FORCE=false
TASK="${1:-}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            if [[ -z "$TASK" ]]; then
                TASK="$1"
            fi
            shift
            ;;
    esac
done

# Execute command with dry run support
execute() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would execute: $description"
        log "[DRY RUN] Command: $cmd"
        return 0
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        log "Executing: $description"
        log "Command: $cmd"
    fi
    
    if eval "$cmd"; then
        success "$description completed"
    else
        error "$description failed"
        return 1
    fi
}

# Confirm action
confirm() {
    local message="$1"
    
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        log "Operation cancelled by user"
        return 1
    fi
}

# Cleanup old generations
cleanup_generations() {
    log "Starting cleanup of old generations..."
    
    if [[ ! -f /etc/nixos/configuration.nix ]]; then
        warning "Not running on NixOS, skipping generation cleanup"
        return 0
    fi
    
    # Keep last 5 generations
    execute "sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system" \
            "Deleting old system generations"
    
    # Clean user profiles
    execute "nix-env --delete-generations +5" \
            "Deleting old user generations"
    
    # Garbage collect
    execute "sudo nix-collect-garbage -d" \
            "Running garbage collection"
    
    # Optimize store
    execute "sudo nix store --optimize" \
            "Optimizing nix store"
    
    success "Cleanup completed"
}

# Backup configuration
backup_configuration() {
    log "Starting backup process..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/backup_$timestamp"
    
    mkdir -p "$backup_path"
    
    # Backup repository
    execute "cp -r '$REPO_ROOT' '$backup_path/repo'" \
            "Backing up repository"
    
    # Backup system configuration if on NixOS
    if [[ -f /etc/nixos/configuration.nix ]]; then
        execute "sudo cp -r /etc/nixos '$backup_path/system'" \
                "Backing up system configuration"
    fi
    
    # Backup current generation info
    if [[ -f /etc/nixos/configuration.nix ]]; then
        execute "nix-env --list-generations --profile /nix/var/nix/profiles/system > '$backup_path/generations.txt'" \
                "Saving generation information"
    fi
    
    # Create backup summary
    cat > "$backup_path/README.txt" << EOF
Backup created: $(date)
Repository: $REPO_ROOT
Host: $(hostname)
NixOS version: $(nixos-version 2>/dev/null || echo "N/A")

Contents:
- repo/: Repository backup
- system/: System configuration backup (if available)
- generations.txt: Generation information (if available)
EOF
    
    success "Backup completed: $backup_path"
}

# Update flake and dependencies
update_dependencies() {
    log "Updating flake inputs and dependencies..."
    
    cd "$REPO_ROOT"
    
    # Update flake inputs
    execute "nix flake update" \
            "Updating flake inputs"
    
    # Check for breaking changes
    execute "nix flake check" \
            "Checking for breaking changes"
    
    success "Dependencies updated"
}

# Validate all configurations
validate_configurations() {
    log "Validating all configurations..."
    
    cd "$REPO_ROOT"
    
    # Check flake
    execute "nix flake check" \
            "Checking flake configuration"
    
    # Validate each host
    for host in hosts/*/; do
        if [[ -d "$host" ]]; then
            hostname=$(basename "$host")
            execute "nix eval .#nixosConfigurations.$hostname.config.system.build.toplevel.drvPath" \
                    "Validating $hostname configuration"
        fi
    done
    
    success "Configuration validation completed"
}

# Analyze configuration performance
analyze_performance() {
    log "Analyzing configuration performance..."
    
    cd "$REPO_ROOT"
    
    # Run performance analysis
    execute "python test-advanced.py" \
            "Running performance analysis"
    
    # Generate performance report
    local report_file="$REPO_ROOT/logs/performance_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
Performance Analysis Report
Generated: $(date)
Repository: $REPO_ROOT

Configuration Statistics:
EOF
    
    # Count files and lines
    local file_count=$(find . -name "*.nix" | wc -l)
    local line_count=$(find . -name "*.nix" -exec wc -l {} + | tail -1 | awk '{print $1}')
    
    echo "- Nix files: $file_count" >> "$report_file"
    echo "- Total lines: $line_count" >> "$report_file"
    
    # Module analysis
    echo "" >> "$report_file"
    echo "Module Distribution:" >> "$report_file"
    for module in nixos home lib hosts; do
        local count=$(find "$module" -name "*.nix" 2>/dev/null | wc -l)
        echo "- $module: $count files" >> "$report_file"
    done
    
    success "Performance analysis completed: $report_file"
}

# Generate maintenance report
generate_report() {
    log "Generating maintenance report..."
    
    local report_file="$REPO_ROOT/logs/maintenance_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# NixOS Configuration Maintenance Report

**Generated:** $(date)  
**Repository:** $REPO_ROOT  
**Host:** $(hostname)  

## System Information

- **NixOS Version:** $(nixos-version 2>/dev/null || echo "N/A")
- **Kernel:** $(uname -r)
- **Uptime:** $(uptime -p 2>/dev/null || uptime)

## Configuration Statistics

EOF
    
    # Add configuration statistics
    cd "$REPO_ROOT"
    local file_count=$(find . -name "*.nix" | wc -l)
    local line_count=$(find . -name "*.nix" -exec wc -l {} + | tail -1 | awk '{print $1}')
    
    echo "- **Nix Files:** $file_count" >> "$report_file"
    echo "- **Total Lines:** $line_count" >> "$report_file"
    
    # Add host information
    echo "" >> "$report_file"
    echo "## Host Configurations" >> "$report_file"
    for host in hosts/*/; do
        if [[ -d "$host" ]]; then
            hostname=$(basename "$host")
            echo "- **$hostname:** Configuration exists" >> "$report_file"
        fi
    done
    
    # Add system health
    echo "" >> "$report_file"
    echo "## System Health" >> "$report_file"
    
    if [[ -f /etc/nixos/configuration.nix ]]; then
        # Disk usage
        local disk_usage=$(df / | awk 'NR==2 {print $5}')
        echo "- **Disk Usage:** $disk_usage" >> "$report_file"
        
        # Memory usage
        local mem_usage=$(free | awk 'NR==2{printf "%.0f%%", $3*100/$2}')
        echo "- **Memory Usage:** $mem_usage" >> "$report_file"
        
        # Failed services
        local failed_services=$(systemctl --failed --no-legend | wc -l)
        echo "- **Failed Services:** $failed_services" >> "$report_file"
    fi
    
    # Add recent activity
    echo "" >> "$report_file"
    echo "## Recent Activity" >> "$report_file"
    echo "- **Last Backup:** $(ls -1t "$BACKUP_DIR" 2>/dev/null | head -1 | sed 's/backup_//' || echo 'None')" >> "$report_file"
    echo "- **Last Update:** $(git log -1 --format="%h %s" 2>/dev/null || echo 'N/A')" >> "$report_file"
    
    success "Maintenance report generated: $report_file"
}

# Run comprehensive health checks
run_health_checks() {
    log "Running comprehensive health checks..."
    
    cd "$REPO_ROOT"
    
    # Run all test suites
    execute "python test-config.nix" \
            "Running basic structure tests"
    
    execute "python test-advanced.py" \
            "Running advanced tests"
    
    execute "python test-window-managers.py" \
            "Running window manager tests"
    
    execute "python test-security.py" \
            "Running security tests"
    
    # System health checks
    if [[ -f /etc/nixos/configuration.nix ]]; then
        # Check disk space
        local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [[ $disk_usage -gt 80 ]]; then
            warning "High disk usage: ${disk_usage}%"
        else
            success "Disk usage OK: ${disk_usage}%"
        fi
        
        # Check memory usage
        local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [[ $mem_usage -gt 90 ]]; then
            warning "High memory usage: ${mem_usage}%"
        else
            success "Memory usage OK: ${mem_usage}%"
        fi
        
        # Check failed services
        local failed_services=$(systemctl --failed --no-legend | wc -l)
        if [[ $failed_services -gt 0 ]]; then
            warning "$failed_services failed services"
        else
            success "No failed services"
        fi
    fi
    
    success "Health checks completed"
}

# Optimize nix store and configurations
optimize_system() {
    log "Optimizing system..."
    
    # Clean nix store
    execute "nix store gc" \
            "Cleaning nix store"
    
    # Optimize store
    execute "nix store --optimize" \
            "Optimizing nix store"
    
    # Check for duplicate store paths
    execute "nix store --query --requisites --size .#nixosConfigurations.athena.config.system.build.toplevel 2>/dev/null | head -10" \
            "Analyzing store usage"
    
    success "System optimization completed"
}

# Start monitoring daemon
start_monitoring() {
    log "Starting monitoring daemon..."
    
    local monitor_script="$REPO_ROOT/scripts/monitor.sh"
    
    if [[ ! -f "$monitor_script" ]]; then
        warning "Monitor script not found: $monitor_script"
        return 1
    fi
    
    execute "nohup bash '$monitor_script' > '$REPO_ROOT/logs/monitor.log' 2>&1 &" \
            "Starting monitoring daemon"
    
    success "Monitoring daemon started"
}

# Run all maintenance tasks
run_all_tasks() {
    log "Running all maintenance tasks..."
    
    # Confirm if not forced
    if ! confirm "This will run all maintenance tasks including cleanup and optimization. Continue?"; then
        return 1
    fi
    
    # Run tasks in order
    update_dependencies
    validate_configurations
    run_health_checks
    analyze_performance
    cleanup_generations
    backup_configuration
    generate_report
    
    success "All maintenance tasks completed"
}

# Main execution
main() {
    # Setup directories
    setup_directories
    
    # Show help if requested
    if [[ "$TASK" == "-h" || "$TASK" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Check if task is provided
    if [[ -z "$TASK" ]]; then
        error "Task is required"
        show_help
        exit 1
    fi
    
    log "Starting NixOS Configuration Maintenance"
    log "Task: $TASK"
    log "Repository: $REPO_ROOT"
    
    # Change to repository root
    cd "$REPO_ROOT"
    
    # Execute task
    case "$TASK" in
        "cleanup")
            cleanup_generations
            ;;
        "backup")
            backup_configuration
            ;;
        "update")
            update_dependencies
            ;;
        "validate")
            validate_configurations
            ;;
        "analyze")
            analyze_performance
            ;;
        "report")
            generate_report
            ;;
        "health")
            run_health_checks
            ;;
        "optimize")
            optimize_system
            ;;
        "monitor")
            start_monitoring
            ;;
        "all")
            run_all_tasks
            ;;
        *)
            error "Unknown task: $TASK"
            show_help
            exit 1
            ;;
    esac
    
    success "Maintenance script completed successfully"
}

# Trap for cleanup
trap 'error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
