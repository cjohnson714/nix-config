/**
  Performance optimization utilities for NixOS configuration.
  Provides advanced performance tuning and optimization capabilities.
*/

{ lib, pkgs, ... }:

{
  # Performance optimization framework
  performance = {
    # System-level performance optimizations
    systemOptimizations = {
      # CPU and scheduler optimizations
      cpu = {
        # Enable CPU frequency scaling
        powerManagement.enable = lib.mkDefault true;
        
        # CPU governor settings
        cpuFreqGovernor = lib.mkDefault "performance";
        
        # Enable Intel P-state if available
        services.power-profiles-daemon.enable = lib.mkDefault true;
      };
      
      # Memory management optimizations
      memory = {
        # Enable zram for compressed swap
        zram.enable = lib.mkDefault true;
        zram.memoryPercent = lib.mkDefault 50;
        
        # Swappiness settings
        vm.swappiness = lib.mkDefault 10;
        vm.vfsCachePressure = lib.mkDefault 50;
        
        # Enable transparent huge pages
        boot.kernel.sysctl."vm.nr_hugepages" = lib.mkDefault 1024;
      };
      
      # I/O and storage optimizations
      storage = {
        # Enable I/O scheduler tuning
        boot.kernel.sysctl."vm.dirty_ratio" = lib.mkDefault 15;
        boot.kernel.sysctl."vm.dirty_background_ratio" = lib.mkDefault 5;
        boot.kernel.sysctl."vm.dirty_expire_centisecs" = lib.mkDefault 1200;
        
        # Enable file system optimizations
        fileSystems."/".options = lib.mkDefault "noatime,errors=remount-ro";
      };
      
      # Network optimizations
      network = {
        # Enable TCP congestion control
        boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
        
        # Network buffer tuning
        boot.kernel.sysctl."net.core.rmem_max" = lib.mkDefault 16777216;
        boot.kernel.sysctl."net.core.wmem_max" = lib.mkDefault 16777216;
        
        # Enable network optimization
        networking.useDHCP = lib.mkDefault false;
      };
    };
    
    # Nix build optimizations
    nixOptimizations = {
      # Parallel builds
      nix.settings = {
        cores = lib.mkDefault 0;  # Use all available cores
        max-jobs = lib.mkDefault "auto";
        sandbox = lib.mkDefault true;
        
        # Binary cache settings
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        
        # Build optimization
        auto-optimise-store = lib.mkDefault true;
        keep-outputs = lib.mkDefault true;
        keep-derivations = lib.mkDefault false;
      };
      
      # Garbage collection optimization
      nix.gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 30d";
      };
      
      # Build optimization
      nix.settings.extra-sandbox-paths = lib.mkDefault [ "/dev" "/proc" "/sys" ];
    };
    
    # Desktop performance optimizations
    desktopOptimizations = {
      # Enable early KMS start
      boot.initrd.kernelModules = lib.mkDefault [ "amdgpu" "i915" "nouveau" ];
      
      # Graphics performance
      hardware.graphics = {
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
      };
      
      # Enable pipewire for low-latency audio
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        alsa.support32Bit = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
      
      # Font rendering optimization
      fonts = {
        enableDefaultPackages = lib.mkDefault true;
        fontconfig = {
          antialias = lib.mkDefault true;
          hinting = lib.mkDefault true;
          subpixel = {
            rgba = lib.mkDefault "rgb";
            lcdfilter = lib.mkDefault "default";
          };
        };
      };
    };
    
    # Application-specific optimizations
    applicationOptimizations = {
      # Browser optimizations
      browsers = {
        # Enable hardware acceleration
        environment."MOZ_ENABLE_WAYLAND" = lib.mkDefault "1";
        environment."NIXOS_OZONE_WL" = lib.mkDefault "1";
        
        # Enable GPU acceleration
        programs.chromium = {
          enable = lib.mkDefault true;
          extraOpts = {
            "EnableHardwareAcceleration" = true;
            "UseOzonePlatform" = true;
          };
        };
      };
      
      # Development optimizations
      development = {
        # Enable compiler optimizations
        environment."CC" = lib.mkDefault "gcc";
        environment."CXX" = lib.mkDefault "g++";
        
        # Enable build optimizations
        environment."CFLAGS" = lib.mkDefault "-O3 -march=native";
        environment."CXXFLAGS" = lib.mkDefault "-O3 -march=native";
        
        # Enable parallel compilation
        environment."MAKEFLAGS" = lib.mkDefault "-j$(nproc)";
      };
      
      # Gaming optimizations
      gaming = {
        # Enable Steam optimizations
        programs.steam = {
          enable = lib.mkDefault true;
          remotePlay.openFirewall = lib.mkDefault true;
          dedicatedServer.openFirewall = lib.mkDefault true;
        };
        
        # Enable gaming mode
        programs.gamemode = {
          enable = lib.mkDefault true;
          enableRenicing = lib.mkDefault true;
        };
        
        # Enable GPU optimization
        environment."DXVK_HUD" = lib.mkDefault "0";
        environment."MANGOHUD" = lib.mkDefault "1";
      };
    };
    
    # Monitoring and profiling
    monitoring = {
      # Enable system monitoring
      services.sysstat = {
        enable = lib.mkDefault true;
        interval = lib.mkDefault 10;
      };
      
      # Enable performance monitoring
      programs.ripgrep.enable = lib.mkDefault true;
      programs.htop.enable = lib.mkDefault true;
      programs.iotop.enable = lib.mkDefault true;
      programs.nethogs.enable = lib.mkDefault true;
      
      # Enable profiling tools
      environment.systemPackages = with pkgs; [
        linuxPackages.perf
        strace
        ltrace
        valgrind
        gdb
      ];
    };
    
    # Apply all optimizations
    enableAll = {
      imports = [
        performance.systemOptimizations
        performance.nixOptimizations
        performance.desktopOptimizations
        performance.applicationOptimizations
        performance.monitoring
      ];
    };
  };
}
