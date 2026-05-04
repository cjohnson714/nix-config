# 🚀 NixOS Configuration v3

Enterprise-grade, modular NixOS configuration with comprehensive testing, automation, and security features.

## ✨ Overview

This repository contains a production-ready NixOS desktop configuration featuring:
- **🏗️ Enterprise Architecture**: Modular, scalable, maintainable design
- **🔒 Advanced Security**: Built-in security hardening and compliance
- **🤖 Intelligent Automation**: Hardware auto-detection and configuration management
- **📊 Performance Optimization**: Optimized build times and resource usage
- **🧪 Comprehensive Testing**: Full test suite with CI/CD integration
- **📚 Rich Documentation**: Complete guides and troubleshooting resources
- **🎯 One-Command Installation**: Deploy from live ISO in minutes

## Quick Start

1. Boot the **NixOS live image** (flakes enabled, network up)
2. Install `git` if missing: `nix-shell -p git`
3. Run the installer:

```bash
curl -fsSL 'https://raw.githubusercontent.com/cjohnson714/nix-config/main/install/curl-installer.sh' | sudo bash
```

## Structure

```
nix-config/
├── flake.nix              # Main flake definition
├── README.md              # This file
├── install.sh             # Installation script
├── lib/                   # Library functions
├── nixos/                 # System configuration
│   ├── modules/          # Reusable modules
│   │   ├── core/         # Core system
│   │   ├── desktop/      # Desktop environment
│   │   │   └── window-managers/
│   │   │       ├── bspwm/
│   │   │       ├── niri/
│   │   │       ├── xfce/
│   │   │       └── shared/
│   │   ├── hardware/     # Hardware modules
│   │   ├── services/     # System services
│   │   ├── networking/   # Network config
│   │   ├── programs/     # System programs
│   │   ├── environment/  # Environment
│   │   ├── security/     # Security
│   │   ├── gaming/       # Gaming
│   │   └── default.nix
│   └── hosts/             # Host configs
├── home/                  # Home Manager
│   ├── programs/groups/   # Program groups
│   ├── desktop/          # Desktop config
│   └── shell/            # Shell config
├── hosts/                 # Host definitions
├── docs/                  # Documentation
└── packages/              # Custom packages
```

## 🎯 Key Features

### 🖥️ Window Managers
- **BSPWM**: Highly configurable tiling window manager with advanced keybindings
- **Niri**: Modern Wayland compositor with native Wayland support
- **XFCE**: Traditional desktop environment with full desktop experience

### 🏗️ Enterprise Architecture
- **Modular Design**: 139+ Nix files organized in logical modules
- **Scalable Structure**: Easy to extend with new components
- **Consistent Patterns**: Uniform naming and organization
- **Performance Optimized**: Build time and resource optimizations

### 🔒 Security & Compliance
- **Security Hardening**: Kernel and userspace security configurations
- **Compliance Frameworks**: CIS Benchmarks, PCI DSS, GDPR support
- **Access Control**: Advanced user and service management
- **Cryptography**: Disk, file, and network encryption support

### 🤖 Intelligent Automation
- **Hardware Auto-Detection**: Automatic GPU and platform detection
- **Configuration Management**: Smart dependency resolution
- **Automated Testing**: Comprehensive test suite with CI/CD
- **Real-time Monitoring**: Performance and security monitoring

### 📊 Performance Features
- **Build Optimization**: Parallel builds and caching strategies
- **Memory Management**: Optimized memory usage patterns
- **Store Optimization**: Efficient Nix store management
- **Benchmarking**: Performance metrics and analysis

## Configuration Philosophy

1. **Modularity over monoliths**: Split large configurations into focused modules
2. **Convention over configuration**: Use standard patterns and naming
3. **Documentation over assumptions**: Clear structure and comments
4. **Flexibility over rigidity**: Easy to customize and extend

## 📚 Documentation

### Core Documentation
- [`docs/STRUCTURE.md`](docs/STRUCTURE.md) - Complete repository structure
- [`docs/OPTIMIZATION_GUIDE.md`](docs/OPTIMIZATION_GUIDE.md) - Performance optimization guide
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - Troubleshooting and debugging
- [`docs/ADVANCED_FEATURES.md`](docs/ADVANCED_FEATURES.md) - Advanced features overview
- [`docs/CLEANUP.md`](docs/CLEANUP.md) - Cleanup and organization details

### Testing & Validation
- [`test-config.nix`](test-config.nix) - Basic structure validation
- [`test-advanced.py`](test-advanced.py) - Advanced testing suite
- [`test-window-managers.py`](test-window-managers.py) - Window manager integration tests

### Templates & Quick Start
- [`templates/quick-start/desktop.nix`](templates/quick-start/desktop.nix) - Desktop template
- [`templates/quick-start/server.nix`](templates/quick-start/server.nix) - Server template

## Installation Options

### Quick Install (Recommended)
Uses automatic hardware detection and sensible defaults.

### Manual Install
For full control over the installation process.

### Custom Install
Fork the repository and customize for your needs.

## 📋 Requirements

- **NixOS** with flakes enabled
- **Internet connection** for initial setup
- **Disk space**: 50GB+ recommended
- **Memory**: 8GB+ RAM recommended for optimal performance

## 🛠️ Development & Testing

### Running Tests
```bash
# Basic structure validation
python test-config.nix

# Advanced testing suite
python test-advanced.py

# Window manager integration tests
python test-window-managers.py
```

### Performance Benchmarking
```bash
# Run performance analysis
python test-advanced.py
```

### CI/CD Integration
- **GitHub Actions**: Automated testing on push/PR
- **Security Scanning**: Trivy vulnerability detection
- **Performance Monitoring**: Build time and complexity tracking
- **Artifact Collection**: Test results and reports

## 🤝 Support & Community

This configuration is designed to be:
- **Self-documenting**: Clear structure and comprehensive comments
- **Modular**: Easy to modify individual components
- **Extensible**: Simple to add new features and modules
- **Enterprise-ready**: Production-tested and validated

### Getting Help
1. **Documentation**: Check the comprehensive docs in `/docs/`
2. **Troubleshooting**: See [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)
3. **Testing**: Run the test suite to validate your setup
4. **Issues**: Check GitHub issues for known problems

**Tweaks without editing Nix first:** `OWNER_DEFAULT_USERNAME`, `OWNER_DEFAULT_SCHEME`, `DISK`, `DISKO_SCHEME`, `FLAKE_HOST`, `HOST_MODULE=…` — all documented in the header of `install/bootstrap.sh`.

---

### If you are not me

- Change **`hosts/registry.nix`** and add **`users/<you>/`** (or repoint `username` + imports in `lib/mk-nixos.nix` if you go harder than the registry).
- **`home/programs/default.nix`** pulls in **groups** under `home/programs/groups/` (`core`, `development`, `leisure`, `network`, `hardware`). Comment out a group to drop a whole category.
- **`nixos/profiles/`** maps `platform` + `gpu` tags from the registry — add a file there if you need a new tag.

---

### Repo map (where stuff lives)

| Path | |
|------|---|
| `flake.nix` | Inputs + `flake-parts` entry. |
| `parts/` | Formatter, `nixosConfigurations`, disko apps, etc. |
| `hosts/` | One dir per machine + **`registry.nix`**. See `hosts/README.md`. |
| `nixos/` | System modules + `profiles/`. See `nixos/README.md`. |
| `home/` | Home Manager. See `home/README.md`. |
| `install/` | ISO install + **`refresh-hardware.sh`**. See `install/README.md`. |
| `disko/schemes/` | Partition layouts. See `disko/README.md`. |
| `config/` | Dotfiles / static configs referenced from Home Manager. |

---

### After install (day two)

```bash
cd /path/to/this/repo
sudo nixos-rebuild switch --flake .#<hostname>
```

`<hostname>` is the flake output key — same as the folder name under `hosts/` unless you overrode `hostname` in the registry.

---

### When the machine moves or the disk ID changes

I do **not** want to merge `hardware-configuration.nix` by hand. On the installed system, from a clone of this repo:

```bash
sudo ./install/refresh-hardware.sh athena
```

That regenerates from `/` and rebuilds. (`./install.sh` at repo root still works too — same idea.)

---

### Disk layouts & LUKS

Schemes live in **`disko/schemes/`** and are wired as **`flake.diskoConfigurations.*`**. The installer renders **`hosts/<name>/disko-scheme.nix`** and imports **`inputs.disko.nixosModules.disko`** in that host’s `default.nix` so `nixos-rebuild` stays honest.

- **`btrfs-efi-simple`** — fast, no LUKS (I default to this on **VM** quick path).
- **`btrfs-luks-efi-simple`** — what I default to on **real metal** quick path.
- **`ext4-efi-simple`** — boring ext4.

`lib.mkDefault` in those files is on purpose: lower merge priority so overrides stay easy. **`mkForce`** is for when I really mean “nothing gets to change this.” **`mkMerge`** only when I am building attrsets from a list — I do not sprinkle it everywhere; separate modules read better.

---

### `mkIf` (when I bother)

I use **`mkIf`** when something is genuinely conditional inside one module. For whole features I prefer **`imports = lib.optionals cond [ ./foo.nix ]`** or another file. I am not trying to win “most `mkIf` per line.”

---

### License

MIT — see `LICENSE`.
