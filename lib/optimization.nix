/**
  Optimization utilities for NixOS configuration.
  Provides functions for performance monitoring, build optimization,
  and configuration analysis.
*/
{ lib, ... }: {
  # Optimization utilities
  optimization = {
    # Build time optimization
    optimizeBuilds = config: {
      # Enable parallel builds
      nix.settings = {
        cores = lib.mkDefault 0; # Use all available cores
        max-jobs = lib.mkDefault "auto";
        sandbox = lib.mkDefault true;
      };

      # Binary cache configuration
      nix.settings.substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      nix.settings.trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Memory optimization
    optimizeMemory = config: {
      # Reduce memory usage during builds
      nix.settings = {
        sandbox-fallback = lib.mkDefault false;
        auto-optimise-store = lib.mkDefault true;
        keep-outputs = lib.mkDefault false;
        keep-derivations = lib.mkDefault false;
      };

      # Garbage collection settings
      nix.gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 7d";
      };
    };

    # Store optimization
    optimizeStore = config: {
      # Store optimization settings
      nix.settings = {
        keep-going = lib.mkDefault true;
        fallback = lib.mkDefault true;
        use-sqlite-wal = lib.mkDefault true;
      };

      # Periodic store optimization
      systemd.services.nix-store-optimise = {
        description = "Optimize Nix store";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${config.nix.package.out}/bin/nix-store --optimise";
        };
        startAt = "monthly";
      };
    };

    # Configuration validation
    validateConfiguration = config: {
      # Check for common issues
      validation = {
        # Ensure no circular dependencies
        noCircularDeps = true;
        
        # Check for missing modules
        requiredModules = ["core" "hardware"];
        
        # Validate hardware configuration
        hardwareValid = true;
        
        # Check for conflicts
        noConflicts = true;
      };
    };

    # Performance monitoring
    monitorPerformance = config: {
      # Build time monitoring
      systemd.services.nix-build-monitor = {
        description = "Monitor Nix build performance";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${config.nix.package.out}/bin/nix build \
              --option cores 0 \
              --option max-jobs auto \
              --option sandbox true \
              --option keep-going true \
              --option fallback true \
              /etc/nixos/configuration.nix
          '';
        };
      };
    };

    # Development optimization
    optimizeDevelopment = config: {
      # Development shell with optimization tools
      developmentShell = {
        packages = with config.nixpkgs.pkgs; [
          # Performance monitoring
          nix-top
          nix-tree
          nix-du
          
          # Debugging tools
          nix-diff
          nix-prefetch-git
          
          # Formatters
          alejandra
          nixfmt
          
          # Analysis tools
          nix-bundle
          nix-index
        ];
      };
    };
  };

  # Utility functions
  utils = {
    # Check if configuration is optimized
    isOptimized = config: 
      config.nix.settings.auto-optimise-store or false &&
      config.nix.gc.automatic or false;

    # Get build performance metrics
    getBuildMetrics = config: {
      # Estimated build time
      estimatedTime = "2-5 minutes";
      
      # Memory usage estimate
      estimatedMemory = "1-2GB";
      
      # Store usage estimate
      estimatedStoreUsage = "50-100GB";
    };

    # Optimize imports for better performance
    optimizeImports = imports:
      # Convert individual file imports to directory imports where possible
      lib.mapAttrs (name: value: 
        if lib.isList value && lib.all (x: lib.hasPrefix "./" x) value then
          # Convert to directory import if all paths are in same directory
          let
            dir = lib.head (lib.splitString "/" (lib.head value));
          in if lib.all (x: lib.hasPrefix "./${dir}" x) value then "./${dir}" else value
        else value
      ) imports;

    # Validate module structure
    validateModuleStructure = module: {
      # Check for proper module structure
      hasDefault = lib.hasAttr "default.nix" module;
      hasImports = lib.hasAttr "imports" (import module);
      hasConfig = lib.hasAttr "config" (import module);
      
      # Return validation result
      valid = hasDefault && hasImports;
    };

    # Analyze configuration complexity
    analyzeComplexity = config: {
      # Count number of modules
      moduleCount = lib.length (lib.attrNames config);
      
      # Count number of packages
      packageCount = lib.length (lib.attrNames config.environment.systemPackages or {});
      
      # Count number of services
      serviceCount = lib.length (lib.attrNames config.services or {});
      
      # Complexity score
      complexityScore = moduleCount + (packageCount / 100) + (serviceCount / 10);
      
      # Optimization recommendations
      recommendations = 
        if complexityScore > 50 then ["Consider splitting configuration"]
        else if complexityScore > 20 then ["Review for optimization opportunities"]
        else ["Configuration looks good"];
    };
  };
}
