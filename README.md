
# NixOS Config

This repository contains my personal NixOS configuration, utilizing flakes for managing system and user environments. It's designed to be easy to clone and use with minimal setup steps. Most of the content is derived from [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## Directory Structure

```plaintext
.
├── flake.nix                            # Main flake configuration
├── flake.lock                           # Flake lock file for consistent builds
├── home                                 # Home Manager configurations for individual setups
│   ├── bspwm                            # BSPWM window manager setup
│   ├── programs                         # Configuration for programs and applications
│   ├── rofi                             # Rofi launcher setup
│   ├── shell                            # Shell setup, including terminals and prompts
│   ├── core.nix                         # Home Manager core initialization
├── host                                 # Host-specific configurations
│   ├── nixos-vm                         # NixOS VM configuration for this machine
│   │   ├── default.nix                  # Main system configuration for nixos-vm
│   │   └── hardware-configuration.nix   # Auto-generated hardware config for nixos-vm
├── modules                              # Shared system configurations and custom modules
│   ├── bspwm.nix                        # Installation and enabling of BSPWM
│   └── system.nix                       # Shared system-level settings
├── users                                # User-specific configuration files
│   └── integrus                         # User-specific Home Manager and NixOS settings
│       ├── home.nix                     # Imports all Home Manager configurations for user
│       └── nixos.nix                    # User-specific NixOS settings
├── wallpaper.jpg                        # Wallpaper image used for desktop background
```

## Setting up NixOS with Flakes

To use this configuration on a fresh NixOS system, follow these steps:

1. **Clone the Repository:**

   Clone this repository to your machine:

   ```bash
   git clone https://github.com/yourusername/nix-config.git
   cd nix-config
   ```

2. **Enable Flakes (if needed):**

   If you haven't already enabled flakes in your NixOS installation, you can do so by adding the following to your `configuration.nix`:

   ```nix
   nix.settings.experimentalFeatures = [ "flakes" ];
   ```

   Then, run:

   ```bash
   sudo nixos-rebuild switch
   ```

   This will enable flakes support, allowing you to use the `--flake` option with `nixos-rebuild`.

3. **Apply the Configuration:**

   To apply the configuration, simply run the following command:

   ```bash
   sudo nixos-rebuild switch --flake .#nixos-vm
   ```

   This will rebuild and switch to the NixOS configuration specified for the `nixos-vm` host.

## Notes

- The `flake.nix` file is the entry point for both system and Home Manager configurations.
- The structure is modularized so that you can easily modify individual components like `bspwm`, `rofi`, or `programs`.
- The configuration is primarily intended for use with virtual machines (VMs) but can be adapted for physical machines.
- **Home Manager** is used for user-specific configurations, allowing for a consistent and portable setup across systems.
  
## Reference

Most of this configuration is adapted from [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).
