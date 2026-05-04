/**
  Validation utilities for NixOS configuration.
  Provides functions to validate and check configuration consistency.
*/
{ lib, ... }: {
  # Validation functions
  validators = {
    # Check if required modules are present
    checkRequiredModules = requiredModules: config:
      let
        missing = lib.filter (module: !lib.hasAttr module config) requiredModules;
      in
      if missing == [] then true
      else throw "Missing required modules: ${lib.concatStringsSep ", " missing}";
    
    # Validate hardware configuration
    validateHardwareConfig = config:
      let
        hasBootLoader = config.boot.loader.grub.enable || config.boot.loader.systemd-boot.enable;
      in
      if !hasBootLoader then throw "No boot loader configured"
      else true;
    
    # Validate user configuration
    validateUserConfig = username: config:
      let
        hasUser = lib.hasAttr username config.users.users;
      in
      if !hasUser then throw "User ${username} not found in configuration"
      else true;
    
    # Check for conflicting configurations
    checkConflicts = config:
      let
        conflicts = lib.filter (s: s != "") [
          # Check for multiple display managers
          (if (config.services.xserver.displayManager.gdm.enable or false) && 
              (config.services.xserver.displayManager.sddm.enable or false)
           then "Multiple display managers enabled (gdm and sddm)"
           else "")
        ];
      in
      if conflicts == [] then true
      else throw "Configuration conflicts found: ${lib.concatStringsSep ", " conflicts}";
  };
  
  # Configuration checker that runs all validations
  checkConfiguration = { username ? "integrus", config, ... }:
    let
      validators = [
        (v: v.validateHardwareConfig config)
        (v: v.validateUserConfig username config)
        (v: v.checkConflicts config)
      ];
    in
    lib.all (fn: fn validators) validators;
}
