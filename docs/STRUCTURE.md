# NixOS Configuration Structure

This document outlines the complete structure of the NixOS configuration repository.

## Repository Overview

```
nix-config/
├── flake.nix              # Main flake definition
├── flake.lock             # Flake lock file
├── README.md              # Main documentation
├── install.sh             # Installation script
├── wallpaper.jpg          # Default wallpaper
├── .gitignore            # Git ignore rules
├── LICENSE               # License file
│
├── lib/                  # Library functions
│   ├── build-hosts.nix   # Host building utilities
│   ├── mk-nixos.nix      # NixOS configuration builder
│   ├── validation.nix    # Configuration validation
│   └── default.nix       # Library exports
│
├── nixos/                 # System configuration
│   ├── modules/          # Reusable system modules
│   │   ├── core/         # Core system configuration
│   │   │   ├── system.nix
│   │   │   ├── kernel.nix
│   │   │   ├── bootloader.nix
│   │   │   ├── users.nix
│   │   │   └── nix-user.nix
│   │   ├── desktop/      # Desktop environment modules
│   │   │   ├── display-management.nix
│   │   │   ├── file-managers.nix
│   │   │   ├── desktop-environment.nix
│   │   │   └── window-managers/
│   │   │       ├── bspwm/
│   │   │       │   ├── core/
│   │   │       │   ├── services/
│   │   │       │   ├── packages/
│   │   │       │   └── config/
│   │   │       ├── niri/
│   │   │       │   ├── core/
│   │   │       │   ├── packages/
│   │   │       │   └── config/
│   │   │       ├── xfce/
│   │   │       │   ├── core/
│   │   │       │   ├── packages/
│   │   │       │   └── config/
│   │   │       └── shared/
│   │   ├── hardware/     # Hardware-specific modules
│   │   │   ├── kernel.nix
│   │   │   ├── udev.nix
│   │   │   ├── gpu/
│   │   │   │   ├── amd.nix
│   │   │   │   ├── intel.nix
│   │   │   │   ├── nvidia.nix
│   │   │   │   ├── none.nix
│   │   │   │   └── qemu.nix
│   │   │   └── platforms/
│   │   │       ├── desktop.nix
│   │   │       ├── laptop.nix
│   │   │       ├── raspberry.nix
│   │   │       └── vm.nix
│   │   ├── services/      # System services
│   │   │   ├── core.nix
│   │   │   └── systemd.nix
│   │   ├── networking/    # Network configuration
│   │   │   └── network-configuration.nix
│   │   ├── programs/      # System programs
│   │   │   └── programs.nix
│   │   ├── environment/   # Environment settings
│   │   ├── security/      # Security configuration
│   │   ├── gaming/        # Gaming configuration
│   │   └── default.nix    # Main module aggregator
│   └── hosts/             # Host-specific configurations
│       ├── athena/
│       └── nixos-vm/
│
├── home/                  # Home Manager configuration
│   ├── default.nix        # Main home configuration
│   ├── core.nix           # Core home settings
│   ├── desktop/           # Desktop-specific home config
│   ├── programs/          # Program configurations
│   │   └── groups/        # Program groups
│   │       ├── core.nix
│   │       ├── development.nix
│   │       ├── leisure.nix
│   │       ├── network.nix
│   │       └── hardware.nix
│   │       └── [various program configs]
│   └── shell/             # Shell configuration
│
├── hosts/                 # Host definitions
│   ├── registry.nix       # Host registry
│   ├── athena/
│   │   └── default.nix
│   └── nixos-vm/
│       └── default.nix
│
├── config/                # Configuration files
├── install/               # Installation utilities
├── docs/                  # Documentation
└── packages/              # Custom packages
```

## Module Organization

### Core Modules
- **system.nix**: Basic system configuration
- **kernel.nix**: Kernel settings and modules
- **bootloader.nix**: Boot configuration
- **users.nix**: User management
- **nix-user.nix**: Nix user configuration

### Desktop Modules
- **display-management.nix**: X11/Wayland display servers
- **file-managers.nix**: File manager configuration
- **desktop-environment.nix**: Desktop services and utilities
- **window-managers/**: Individual window manager configurations

### Hardware Modules
- **gpu/**: GPU-specific configurations
- **platforms/**: Platform-specific settings
- **kernel.nix**: Hardware kernel modules
- **udev.nix**: Device rules

### Service Modules
- **core.nix**: Essential system services
- **systemd.nix**: Systemd configuration
- **networking/**: Network services

## Window Manager Structure

Each window manager follows this pattern:
```
window-manager/
├── core/           # Core window manager configuration
├── services/       # Required services
├── packages/       # Required packages
├── config/         # Configuration files
│   ├── theme.nix
│   ├── keybindings.nix
│   └── autostart.nix
└── default.nix
```

## Naming Conventions

- **Files**: kebab-case (e.g., `window-manager.nix`)
- **Directories**: kebab-case (e.g., `window-managers/`)
- **Options**: camelCase (e.g., `enableWayland`)
- **Modules**: descriptive and single-purpose

## Import Patterns

- Use directory-level imports where possible
- Keep imports at the top of files
- Use relative imports within modules
- Avoid circular dependencies

## Configuration Philosophy

1. **Single Responsibility**: Each module has one clear purpose
2. **Modularity**: Components can be enabled/disabled independently
3. **Consistency**: Uniform structure across all modules
4. **Maintainability**: Easy to understand and modify
5. **Scalability**: Simple to extend with new functionality
