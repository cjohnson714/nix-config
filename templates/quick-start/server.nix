# Quick Start Server Configuration Template
# Copy this file to hosts/your-hostname/default.nix and customize

{ pkgs, lib, ... }:

{
  imports = [
    # Core system modules
    ../../nixos/modules/core
    ../../nixos/modules/hardware
    ../../nixos/modules/services
    ../../nixos/modules/networking
    ../../nixos/modules/programs
    ../../nixos/modules/environment
    ../../nixos/modules/security
  ];

  # Host-specific configuration
  networking.hostName = "your-server";

  # Hardware configuration (auto-detected)
  hardware = {
    # GPU configuration (usually none for servers)
    gpu = "none";
    
    # Platform configuration
    platform = "desktop";  # Usually desktop for servers
  };

  # Server configuration
  server = {
    # Server type
    type = "general";  # Options: "general", "web", "database", "compute", "storage"
    
    # Server features
    enable = {
      # Core server features
      ssh = true;
      firewall = true;
      monitoring = true;
      backup = false;
      
      # Optional features
      webServer = false;
      database = false;
      virtualization = false;
      containerization = false;
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
      ];
      shell = pkgs.bash;
    };
    
    # Additional users (optional)
    additionalUsers = [];
  };

  # System configuration
  system = {
    # System version
    stateVersion = "24.11";
    
    # System features
    features = {
      # Enable experimental features
      experimentalFeatures = true;
      
      # Enable auto-upgrade (recommended for servers)
      autoUpgrade = true;
      
      # Enable garbage collection
      garbageCollection = true;
      
      # Auto-upgrade settings
      autoUpgradeSettings = {
        enable = true;
        dates = "daily";
        allowReboot = false;  # Set to true if automatic reboots are acceptable
      };
    };
  };

  # Network configuration
  network = {
    # Network manager (optional for servers)
    enableNetworkManager = false;
    
    # Static networking (recommended for servers)
    staticNetworking = {
      enable = false;
      ipAddress = "192.168.1.100";
      gateway = "192.168.1.1";
      nameservers = ["8.8.8.8" "8.8.4.4"];
    };
    
    # Firewall
    enableFirewall = true;
    
    # Open ports (configure as needed)
    openPorts = [
      # SSH
      { port = 22; protocol = "tcp"; }
      
      # Web server (if enabled)
      # { port = 80; protocol = "tcp"; }
      # { port = 443; protocol = "tcp"; }
      
      # Database (if enabled)
      # { port = 5432; protocol = "tcp"; }
    ];
  };

  # Security configuration
  security = {
    # Enable sudo
    enableSudo = true;
    
    # Passwordless sudo for wheel group (optional for servers)
    sudoWheelNeedsPassword = true;
    
    # Enable firewall
    enableFirewall = true;
    
    # Enable fail2ban (recommended for servers)
    enableFail2ban = true;
    
    # SSH configuration
    ssh = {
      enable = true;
      port = 22;
      permitRootLogin = "no";
      passwordAuthentication = false;
      keyAuthentication = true;
      
      # SSH keys (add your public keys here)
      authorizedKeys = [
        # "ssh-rsa AAAAB3NzaC1yc2E... your-ssh-key"
      ];
    };
  };

  # Services configuration
  services = {
    # SSH service
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
    
    # Monitoring (optional)
    monitoring = {
      enable = true;
      prometheus = false;
      grafana = false;
      nodeExporter = true;
    };
    
    # Backup (optional)
    backup = {
      enable = false;
      source = "/home";
      destination = "/backup";
      schedule = "daily";
    };
  };

  # Web server (optional)
  webServer = {
    enable = false;
    
    # Web server type
    type = "nginx";  # Options: "nginx", "apache", "caddy"
    
    # Virtual hosts
    virtualHosts = [];
    
    # SSL/TLS
    enableSSL = false;
    sslCertificate = "";
    sslCertificateKey = "";
  };

  # Database (optional)
  database = {
    enable = false;
    
    # Database type
    type = "postgresql";  # Options: "postgresql", "mysql", "mariadb"
    
    # Database configuration
    settings = {
      port = 5432;
      dataDir = "/var/lib/postgresql";
    };
  };

  # Virtualization (optional)
  virtualization = {
    enable = false;
    
    # Virtualization type
    type = "kvm";  # Options: "kvm", "docker", "podman"
    
    # Virtual machines
    virtualMachines = [];
  };

  # Containerization (optional)
  containerization = {
    enable = false;
    
    # Container type
    type = "docker";  # Options: "docker", "podman"
    
    # Containers
    containers = [];
  };

  # Custom packages
  environment.systemPackages = with pkgs; [
    # System administration tools
    htop
    iotop
    nethogs
    tcpdump
    strace
    lsof
    
    # Network tools
    wget
    curl
    rsync
    git
    
    # Filesystem tools
    parted
    gptfdisk
    e2fsprogs
    
    # Add your custom packages here
  ];

  # Custom services
  services = {
    # Add your custom services here
    # Example:
    # printing.enable = false;
    # cron.enable = true;
  };

  # Custom configuration
  # Add any additional configuration here
  # Example:
  # time.timeZone = "UTC";
  # i18n.defaultLocale = "en_US.UTF-8";
  
  # Server-specific settings
  boot = {
    # Kernel parameters (if needed)
    kernelParams = [];
    
    # Kernel modules (if needed)
    kernelModules = [];
    
    # Initrd settings (if needed)
    initrd = {
      availableKernelModules = [];
      kernelModules = [];
    };
  };

  # Filesystem configuration (if needed)
  fileSystems = {
    # Example:
    # "/data" = {
    #   device = "/dev/sdb1";
    #   fsType = "ext4";
    #   options = [ "relatime" ];
    # };
  };

  # Swap configuration (if needed)
  swapDevices = [
    # Example:
    # {
    #   device = "/swapfile";
    #   size = "8G";
    # }
  ];
}
