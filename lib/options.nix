/**
  Common NixOS options and utilities used across the configuration.
  This module provides reusable functions and default values to reduce duplication.
*/
{ lib, ... }: {
  # Utility functions for common patterns
  utils = {
    # Conditional imports based on boolean flag
    optionalImports = condition: imports: 
      lib.optionals condition imports;
    
    # Merge module lists with proper priority
    mergeModules = modules: 
      lib.mkBefore (lib.flatten modules);
    
    # Default hardware configuration with device detection
    mkHardwareConfig = device: {
      boot.loader.grub.device = lib.mkDefault device;
    };
  };

  # Default configuration options
  options = {
    # Boot configuration defaults
    boot = {
      loader = {
        grub = {
          enable = lib.mkDefault false;
          useOSProber = lib.mkDefault true;
          enableCryptodisk = lib.mkDefault false;
        };
        systemd-boot = {
          enable = lib.mkDefault false;
        };
        efi = {
          canTouchEfiVariables = lib.mkDefault true;
          efiSysMountPoint = lib.mkDefault "/boot";
        };
      };
    };

    # System defaults
    system = {
      stateVersion = lib.mkDefault "24.11";
      autoUpgrade = {
        enable = lib.mkDefault false;
        allowReboot = lib.mkDefault false;
      };
    };

    # Home Manager defaults
    home-manager = {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      backupFileExtension = lib.mkDefault "hm-backup";
    };
  };
}
