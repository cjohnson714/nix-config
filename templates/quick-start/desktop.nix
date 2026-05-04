# Quick Start Desktop Configuration Template
# Copy this file to hosts/your-hostname/default.nix and customize

{ pkgs, lib, ... }:

{
  imports = [
    # Core system modules
    ../../nixos/modules/core
    ../../nixos/modules/hardware
    ../../nixos/modules/services
    ../../nixos/modules/networking
    ../../nixos/modules/desktop
    ../../nixos/modules/programs
    ../../nixos/modules/environment
    ../../nixos/modules/security
    ../../nixos/modules/gaming
  ];

  # Host-specific configuration
  networking.hostName = "your-hostname";

  # Hardware configuration (auto-detected)
  hardware = {
    # GPU configuration (auto-detected)
    gpu = "auto";  # Options: "nvidia", "amd", "intel", "none"
    
    # Platform configuration (auto-detected)
    platform = "auto";  # Options: "desktop", "laptop", "vm"
  };

  # Desktop environment
  desktop = {
    # Window manager selection
    windowManager = "bspwm";  # Options: "bspwm", "niri", "xfce"
    
    # Display manager
    displayManager = "sddm";
    
    # Desktop environment features
    enable = {
      # Core desktop features
      desktopServices = true;
      fileManagers = true;
      desktopEnvironment = true;
      
      # Optional features
      gaming = false;
      development = true;
      multimedia = true;
    };
  };

  # User configuration
  users = {
    # Main user
    mainUser = {
      name = "your-username";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "input"
        "disk"
      ];
      shell = pkgs.zsh;
    };
  };

  # System configuration
  system = {
    # System version
    stateVersion = "24.11";
    
    # System features
    features = {
      # Enable experimental features
      experimentalFeatures = true;
      
      # Enable auto-upgrade
      autoUpgrade = false;
      
      # Enable garbage collection
      garbageCollection = true;
    };
  };

  # Network configuration
  network = {
    # Network manager
    enableNetworkManager = true;
    
    # Firewall
    enableFirewall = true;
    
    # VPN (optional)
    enableVPN = false;
  };

  # Security configuration
  security = {
    # Enable sudo
    enableSudo = true;
    
    # Enable passwordless sudo for wheel group
    sudoWheelNeedsPassword = false;
    
    # Enable firewall
    enableFirewall = true;
    
    # Enable fail2ban
    enableFail2ban = false;
  };

  # Development configuration
  development = {
    # Enable development tools
    enableDevelopment = true;
    
    # Programming languages
    languages = {
      nix = true;
      python = false;
      rust = false;
      javascript = false;
      go = false;
    };
    
    # Development tools
    tools = {
      git = true;
      vscode = false;
      docker = false;
      kubernetes = false;
    };
  };

  # Gaming configuration
  gaming = {
    # Enable gaming
    enableGaming = false;
    
    # Gaming platforms
    platforms = {
      steam = false;
      lutris = false;
      heroic = false;
    };
    
    # Gaming tools
    tools = {
      gamemode = false;
      mangohud = false;
      obs = false;
    };
  };

  # Multimedia configuration
  multimedia = {
    # Enable multimedia
    enableMultimedia = true;
    
    # Audio
    audio = {
      enablePipewire = true;
      enableBluetooth = true;
    };
    
    # Video
    video = {
      enableVulkan = false;
      enableNvidia = false;
    };
    
    # Media players
    players = {
      vlc = true;
      mpv = false;
      spotify = false;
    };
  }

  # Custom packages
  environment.systemPackages = with pkgs; [
    # Add your custom packages here
    # Example:
    # htop
    # neofetch
    # wget
    # curl
  ];

  # Custom services
  services = {
    # Add your custom services here
    # Example:
    # openssh.enable = true;
    # printing.enable = true;
  };

  # Custom configuration
  # Add any additional configuration here
  # Example:
  # programs.zsh.enable = true;
  # time.timeZone = "America/New_York";
  # i18n.defaultLocale = "en_US.UTF-8";
}
