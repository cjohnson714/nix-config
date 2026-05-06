# ❄️ NixOS Configuration

This repository contains my evolving NixOS configuration, structured around **Home Manager** and **flakes** to maintain modularity and reproducibility. At present, this setup is optimized for use within a virtual machine, though I am progressively refining it for deployment on bare metal.

---

## 🗂️ Directory Structure

```
.
├── 📜 flake.nix         # Centralized configuration entry point
├── 🔒 flake.lock        # Locks dependency versions for reproducibility
├── 🏠 home              # User environment configurations managed by Home Manager
│   ├── 🖥️ bspwm         # Window manager setup
│   ├── 🛠️ programs      # Application configurations
│   ├── 🚀 rofi          # Launcher settings
│   ├── 🐚 shell         # Shell configurations
│   ├── ⚙️ core.nix      # Core Home Manager settings
├── 🏠 hosts             # Host-specific configurations
│   └── 💻 nixos-vm      # Virtual machine setup
│       ├── 📄 default.nix
│       └── 🔧 hardware-configuration.nix
├── 📦 modules           # System-wide settings and tweaks
│   ├── 🖥️ bspwm.nix     # BSPWM configuration
│   └── ⚙️ system.nix    # General system settings
├── 👤 users             # User-specific configurations
│   └── 🏠 integrus      # Personalized setup
│       ├── 🏡 home.nix
│       └── 🛠️ nixos.nix
└── 🖼️ wallpaper.jpg     # Desktop wallpaper
```

---

## 🚀 Installation & Usage

This guide assumes that you have already installed NixOS and manually handled disk partitioning and mounting according to your preferences. If you have not yet installed NixOS, refer to the [official installation guide](https://nixos.org/download.html).

### 1. 📥 Clone the Repository

```bash
nix-shell -p git --run "git clone https://github.com/cjohnson714/nix-config"
cd nix-config
```

### 2. 🛠️ Generate a Hardware Configuration

Once NixOS is installed, generate a new `hardware-configuration.nix` that reflects your system's hardware:

```bash
sudo nixos-generate-config
```

Replace the default `hardware-configuration.nix` in this repository with the one generated for your system:

```bash
rm hosts/nixos-vm/hardware-configuration.nix
cp /etc/nixos/hardware-configuration.nix hosts/nixos-vm/
```

This step is crucial for ensuring that the configuration properly accounts for your system's hardware, including disk layouts and network interfaces, preventing potential boot failures due to mismatched settings.

Make sure you track the new hardware-configuration.nix if one didn't exist before:

```bash
git add .
```

### 3. ⚡ Apply the Configuration

```bash
sudo nixos-rebuild switch --flake .#nixos-vm --option experimental-features "nix-command flakes"
```

This command applies the system configuration, integrating both system-level settings and Home Manager user configurations. If issues arise, common culprits include incorrect disk identifiers, missing network configurations, or hardware incompatibilities.&#x20;

---

## 💡 Notes

This configuration is currently optimized for a virtual machine but will be expanded for bare-metal deployment in the future. To adapt this setup for a physical machine, define a new host entry in `flake.nix`, create a corresponding directory within `hosts/`, and adjust configurations to match your hardware specifications.

### 🏗️ Defining a New Host

To add a new host, modify `flake.nix` and introduce a corresponding directory within `hosts/`. Below is a simplified example:

```nix
nixosConfigurations = {
  my-machine = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./hosts/my-machine
      ./users/integrus/nixos.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.integrus = import ./users/integrus/home.nix;
      }
    ];
  };
};
```

Ensure you create `hosts/my-machine/default.nix` and tailor it to your system’s needs.

---

## 🙏 Credits & Inspiration

This setup draws significant inspiration from [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config). If you seek a more refined, well-documented configuration, I highly recommend reviewing their repository as a reference.

---

## 📜 License

This configuration is licensed under the MIT License. See the [LICENSE](LICENSE) file for details. Certain aspects of this setup are derived from [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config), which is also licensed under MIT.
