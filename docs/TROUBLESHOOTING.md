# NixOS Configuration Troubleshooting Guide

This guide covers common issues, debugging techniques, and maintenance procedures for the NixOS configuration.

## 🔧 Common Issues

### Build Failures

#### 1. Circular Dependencies
**Symptoms**: Build fails with "infinite recursion" or "cycle detected"

**Detection**:
```bash
nix-instantiate --eval --show-trace --strict
```

**Solutions**:
- Check import chains in affected modules
- Use `lib.mkForce` for conflicting options
- Split circular dependencies into separate modules
- Consider using `mkIf` for conditional imports

**Example Fix**:
```nix
# Before (circular)
# module-a.nix imports module-b.nix
# module-b.nix imports module-a.nix

# After (refactored)
# common.nix - shared functionality
# module-a.nix imports common.nix
# module-b.nix imports common.nix
```

#### 2. Memory Issues
**Symptoms**: Build runs out of memory, system becomes unresponsive

**Detection**:
```bash
# Monitor memory usage
watch -n 1 'free -h && ps aux | head -10'

# Limit memory usage during build
nix build --option sandbox-fallback false --option cores 1
```

**Solutions**:
- Reduce module complexity
- Split large configurations
- Use conditional imports
- Increase swap space temporarily

#### 3. Package Conflicts
**Symptoms**: Multiple versions of same package, dependency conflicts

**Detection**:
```bash
nix build --show-trace --verbose
```

**Solutions**:
- Use `mkForce` for package versions
- Override conflicting packages in `nixpkgs.config`
- Use overlays for custom package versions

**Example**:
```nix
nixpkgs.config = {
  allowUnfree = true;
  packageOverrides = pkgs: {
    # Force specific version
    package = pkgs.package_2_0;
  };
};
```

### Runtime Issues

#### 1. Services Not Starting
**Symptoms**: Service fails to start, status shows failed

**Detection**:
```bash
# Check service status
systemctl status service-name

# View service logs
journalctl -u service-name -f

# Check configuration
nix eval .#nixosConfigurations.hostname.config.services.service-name
```

**Solutions**:
- Verify service configuration syntax
- Check for missing dependencies
- Ensure required files and directories exist
- Review service-specific requirements

#### 2. Hardware Detection Issues
**Symptoms**: Hardware not recognized, drivers not loading

**Detection**:
```bash
# Check hardware detection
lspci -nnk
lsusb
dmesg | grep -i hardware

# Check loaded modules
lsmod | grep -i driver
```

**Solutions**:
- Verify hardware profile selection
- Check kernel module configuration
- Update hardware configuration files
- Consider custom kernel modules

#### 3. Desktop Environment Issues
**Symptoms**: Window manager fails to start, display issues

**Detection**:
```bash
# Check X11/Wayland logs
journalctl -u display-manager
journalctl -u xserver

# Check window manager logs
journalctl -u bspwm
```

**Solutions**:
- Verify display manager configuration
- Check window manager dependencies
- Ensure required packages are installed
- Review graphics driver configuration

## 🐛 Debugging Techniques

### 1. Configuration Validation
```bash
# Check syntax errors
nix-instantiate --eval --strict --show-trace

# Validate flake
nix flake check

# Check specific configuration
nix eval .#nixosConfigurations.hostname.config
```

### 2. Incremental Testing
```bash
# Test individual modules
nix eval .#nixosConfigurations.hostname.config.system.stateVersion

# Test module imports
nix eval .#nixosConfigurations.hostname.config.services

# Build specific components
nix build .#nixosConfigurations.hostname.config.system.build.toplevel
```

### 3. Performance Analysis
```bash
# Build time analysis
time nix build .#nixosConfigurations.hostname.config

# Memory usage analysis
nix-instantiate --eval --json --strict --show-trace .#nixosConfigurations.hostname.config

# Store usage analysis
nix-store --query --requisites --size .#nixosConfigurations.hostname.config.system.build.toplevel
```

## 🔍 Maintenance Procedures

### 1. Regular Updates
```bash
# Update flake inputs
nix flake update

# Check for breaking changes
nix flake check

# Test update
nix build .#nixosConfigurations.hostname.config

# Apply update
sudo nixos-rebuild switch --flake .#hostname
```

### 2. Cleanup Operations
```bash
# Clean old generations
sudo nix-collect-garbage -d

# Clean nix store
nix store gc

# Remove dead store paths
nix store --optimize
```

### 3. Backup and Recovery
```bash
# Backup current configuration
cp -r /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup

# Create rollback point
sudo nixos-rebuild switch --rollback

# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## 🛠️ Development Tools

### 1. Formatters and Linters
```bash
# Format Nix files
nix fmt

# Check formatting
nix flake check

# Use alejandra for formatting
nix run nixpkgs#alejandra -- .
```

### 2. Development Environment
```bash
# Enter development shell
nix develop

# Build with debugging
nix build --keep-going --show-trace

# Test without building
nix eval .#nixosConfigurations.hostname.config
```

### 3. Performance Monitoring
```bash
# Monitor build performance
time nix build .#nixosConfigurations.hostname.config

# Check store efficiency
nix-store --query --size .#nixosConfigurations.hostname.config.system.build.toplevel

# Analyze dependencies
nix-store --query --requisites .#nixosConfigurations.hostname.config.system.build.toplevel
```

## 📋 Common Solutions

### 1. Slow Builds
- **Cause**: Large configuration, many dependencies
- **Solution**: Use binary cache, optimize imports, split configurations

### 2. Memory Issues
- **Cause**: Complex evaluations, large modules
- **Solution**: Reduce complexity, use conditional imports, increase swap

### 3. Import Errors
- **Cause**: Wrong paths, missing files, syntax errors
- **Solution**: Verify paths, check file existence, validate syntax

### 4. Service Failures
- **Cause**: Missing dependencies, configuration errors
- **Solution**: Check logs, verify dependencies, review configuration

### 5. Hardware Issues
- **Cause**: Wrong profile, missing drivers
- **Solution**: Update hardware config, check drivers, verify profiles

## 🚨 Emergency Procedures

### 1. System Won't Boot
```bash
# Boot from live ISO
# Mount system
mount /dev/disk /mnt

# Rollback to working generation
sudo nixos-rebuild switch --rollback --option root /mnt

# Or rebuild with known good configuration
sudo nixos-rebuild switch --flake /path/to/good/config#hostname
```

### 2. Configuration Corruption
```bash
# Restore from backup
cp /etc/nixos/configuration.nix.backup /etc/nixos/configuration.nix

# Rebuild with backup
sudo nixos-rebuild switch

# Check git history for changes
git log --oneline
git checkout <working-commit>
```

### 3. Store Corruption
```bash
# Check store health
nix-store --verify --check-contents

# Repair store
nix-store --repair-path /nix/store/...

# Rebuild if necessary
sudo nixos-rebuild switch --rebuild
```

## 📚 Additional Resources

### Documentation
- [NixOS Manual - Troubleshooting](https://nixos.org/manual/nixos/stable/#sec-troubleshooting)
- [Nix Pills - Debugging](https://nixos.org/guides/nix-pills/)
- [Nix Flakes - Common Issues](https://nixos.wiki/wiki/Flakes#common-issues)

### Tools
- `nix-diff`: Compare configurations
- `nix-prefetch-git`: Check package availability
- `nix-shell`: Test environments
- `nix-env`: Manage user packages

### Community Support
- [NixOS Discourse - Support](https://discourse.nixos.org/c/support)
- [NixOS Matrix - Support](https://matrix.to/#/#nix:nixos.org)
- [GitHub Issues](https://github.com/NixOS/nixpkgs/issues)

## 🔄 Maintenance Schedule

### Weekly
- Check for flake updates
- Run `nix flake check`
- Clean old generations if needed

### Monthly
- Review configuration for optimization opportunities
- Update documentation
- Check store usage and clean if necessary

### Quarterly
- Major configuration review
- Performance analysis
- Backup verification

### Annually
- Complete configuration audit
- Update to new NixOS version
- Major restructuring if needed
