/**
  Profile system for platform and GPU configurations.
  This module provides a centralized way to manage hardware-specific profiles.
*/
{ lib, ... }: {
  # Platform profiles
  platforms = {
    desktop = {
      # Desktop-specific configurations
      services = {
        power-profiles-daemon.enable = lib.mkDefault true;
        thermald.enable = lib.mkDefault true;
      };
      
      # Desktop environment settings
      hardware = {
        pulseaudio.enable = lib.mkDefault true;
        bluetooth.enable = lib.mkDefault true;
      };
    };
    
    laptop = {
      # Laptop-specific configurations
      powerManagement = {
        enable = lib.mkDefault true;
        powertop.enable = lib.mkDefault true;
      };
      
      # Touchpad and battery management
      services = {
        tlp.enable = lib.mkDefault true;
        logind.lidSwitch = lib.mkDefault "suspend";
      };
    };
    
    vm = {
      # Virtual machine optimizations
      virtualisation = {
        qemu.guestAgent.enable = lib.mkDefault true;
      };
      
      # Minimal services for VMs
      services = {
        power-profiles-daemon.enable = lib.mkDefault false;
        thermald.enable = lib.mkDefault false;
      };
    };
    
    raspberry = {
      # Raspberry Pi specific settings
      boot = {
        kernelParams = lib.mkDefault [ "cma=256M" ];
      };
      
      hardware = {
        raspberry-pi = {
          enable = lib.mkDefault true;
        };
      };
    };
  };
  
  # GPU profiles
  gpus = {
    none = {
      # No GPU acceleration
      services.xserver.videoDrivers = lib.mkDefault [ ];
    };
    
    nvidia = {
      # NVIDIA GPU configuration
      services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
      
      hardware = {
        nvidia = {
          modesetting.enable = lib.mkDefault true;
          powerManagement.enable = lib.mkDefault false;
          open = lib.mkDefault false;
          nvidiaSettings = lib.mkDefault true;
        };
      };
    };
    
    amdgpu = {
      # AMD GPU configuration
      services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];
      
      hardware = {
        amdgpu = {
          opencl.enable = lib.mkDefault true;
        };
      };
    };
    
    intel = {
      # Intel GPU configuration
      services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
      
      hardware = {
        intel-gpu-tools.enable = lib.mkDefault true;
      };
    };
    
    qemu = {
      # QEMU virtual GPU
      services.xserver.videoDrivers = lib.mkDefault [ "qxl" "modesetting" ];
      
      hardware = {
        spiceUSBRedirection.enable = lib.mkDefault true;
      };
    };
  };
}
