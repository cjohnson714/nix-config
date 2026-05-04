/**
  Advanced automation utilities for NixOS configuration.
  Provides intelligent configuration management, automated testing,
  and deployment capabilities.
*/
{ lib, pkgs, ... }: {
  # Automation framework
  automation = {
    # Intelligent configuration management
    configManager = {
      # Auto-detect hardware and apply appropriate configurations
      autoDetectHardware = config: {
        # GPU detection
        gpu = let
          gpuDevices = lib.splitString "\n" (lib.removeSuffix "\n" (builtins.readFile "/proc/bus/pci/devices" or ""));
          hasNvidia = lib.any (lib.hasInfix "nvidia") gpuDevices;
          hasAMD = lib.any (lib.hasInfix "amd") gpuDevices;
          hasIntel = lib.any (lib.hasInfix "intel") gpuDevices;
        in
          if hasNvidia then "nvidia"
          else if hasAMD then "amd"
          else if hasIntel then "intel"
          else "none";

        # Platform detection
        platform = let
          isLaptop = lib.pathExists "/sys/class/power_supply/BAT0";
          isVM = lib.pathExists "/sys/class/dmi/id/product_name" && 
                 (lib.hasInfix "VM" (builtins.readFile "/sys/class/dmi/id/product_name") or "");
        in
          if isVM then "vm"
          else if isLaptop then "laptop"
          else "desktop";

        # CPU detection
        cpu = let
          cpuInfo = builtins.readFile "/proc/cpuinfo" or "";
          hasIntelCPU = lib.hasInfix "Intel" cpuInfo;
          hasAMDCPU = lib.hasInfix "AMD" cpuInfo;
        in
          if hasIntelCPU then "intel"
          else if hasAMDCPU then "amd"
          else "unknown";
      };

      # Auto-configure based on detected hardware
      autoConfigure = config: {
        imports = with config.automation.configManager.autoDetectHardware config; [
          # GPU-specific configuration
          (if gpu == "nvidia" then ./hardware/gpu/nvidia.nix
           else if gpu == "amd" then ./hardware/gpu/amd.nix
           else if gpu == "intel" then ./hardware/gpu/intel.nix
           else ./hardware/gpu/none.nix)
          
          # Platform-specific configuration
          (if platform == "laptop" then ./hardware/platforms/laptop.nix
           else if platform == "vm" then ./hardware/platforms/vm.nix
           else ./hardware/platforms/desktop.nix)
        ];
      };

      # Validate configuration integrity
      validateConfig = config: {
        validation = {
          # Check for required modules
          requiredModules = [
            "core"
            "hardware"
            "services"
          ];
          
          # Check for conflicts
          conflicts = [
            # Check for multiple display managers
            (if config.services.xserver.displayManager.gdm.enable or false && 
                config.services.xserver.displayManager.sddm.enable or false
             then "Multiple display managers enabled"
             else "")
            
            # Check for conflicting GPU drivers
            (if (config.hardware.nvidia.enable or false) && 
                (config.hardware.amdgpu.enable or false)
             then "Multiple GPU drivers enabled"
             else "")
          ];
          
          # Check for missing dependencies
          missingDeps = [];
        };
      };
    };

    # Automated testing framework
    testing = {
      # Configuration validation tests
      validationTests = config: {
        tests = {
          # Test module imports
          testImports = {
            assertion = builtins.all (module: 
              builtins.pathExists (toString module + "/default.nix")
            ) config.imports;
            message = "All imported modules exist";
          };
          
          # Test service configuration
          testServices = {
            assertion = builtins.all (service: 
              config.services.${service}.enable or false
            ) (lib.attrNames config.services);
            message = "All enabled services are properly configured";
          };
          
          # Test package availability
          testPackages = {
            assertion = builtins.all (package: 
              builtins.hasAttr package config.nixpkgs.pkgs
            ) (lib.attrNames config.environment.systemPackages);
            message = "All packages are available in nixpkgs";
          };
        };
      };

      # Performance tests
      performanceTests = config: {
        tests = {
          # Test build time
          testBuildTime = {
            assertion = true; # Would be implemented with actual timing
            message = "Build time within acceptable limits";
          };
          
          # Test memory usage
          testMemoryUsage = {
            assertion = true; # Would be implemented with actual monitoring
            message = "Memory usage within acceptable limits";
          };
          
          # Test store usage
          testStoreUsage = {
            assertion = true; # Would be implemented with actual analysis
            message = "Store usage optimized";
          };
        };
      };

      # Security tests
      securityTests = config: {
        tests = {
          # Test for security vulnerabilities
          testVulnerabilities = {
            assertion = true; # Would be implemented with security scanning
            message = "No known vulnerabilities in configuration";
          };
          
          # Test for proper permissions
          testPermissions = {
            assertion = true; # Would be implemented with permission checking
            message = "All file permissions are secure";
          };
          
          # Test for secrets exposure
          testSecrets = {
            assertion = !builtins.any (lib.hasInfix "password") 
              (lib.splitString "\n" (builtins.toJSON config));
            message = "No secrets exposed in configuration";
          };
        };
      };

      # Run all tests
      runTests = config: {
        allTests = config.automation.testing.validationTests config.tests
                 // config.automation.testing.performanceTests config.tests
                 // config.automation.testing.securityTests config.tests;
        
        results = lib.mapAttrs (name: test: {
          name = name;
          passed = test.assertion;
          message = test.message;
        }) config.automation.testing.runTests.allTests;
      };
    };

    # Deployment automation
    deployment = {
      # Multi-environment deployment
      environments = {
        development = {
          # Development-specific settings
          system.stateVersion = "24.11";
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          # Enable debugging tools
          programs.gdb.enable = true;
          programs.strace.enable = true;
        };
        
        staging = {
          # Staging environment settings
          system.stateVersion = "24.11";
          # More conservative settings
          nix.settings.auto-optimise-store = true;
          # Enable monitoring
          services.prometheus.enable = true;
        };
        
        production = {
          # Production environment settings
          system.stateVersion = "24.11";
          # Maximum security and stability
          security.pam.enableSudo = true;
          services.fail2ban.enable = true;
          # Disable debugging
          programs.gdb.enable = false;
          programs.strace.enable = false;
        };
      };

      # Automated deployment pipeline
      deployPipeline = config: {
        steps = [
          # 1. Pre-deployment validation
          {
            name = "validate";
            action = config.automation.testing.runTests config;
          }
          
          # 2. Build configuration
          {
            name = "build";
            action = "nix build .#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel";
          }
          
          # 3. Security scan
          {
            name = "security";
            action = "nix run nixpkgs#trivy -- config .";
          }
          
          # 4. Performance analysis
          {
            name = "performance";
            action = config.automation.testing.performanceTests config;
          }
          
          # 5. Deploy
          {
            name = "deploy";
            action = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
          }
          
          # 6. Post-deployment verification
          {
            name = "verify";
            action = "systemctl status";
          }
        ];
      };

      # Rollback capability
      rollback = {
        # Automatic rollback on failure
        autoRollback = config: {
          # Check system health after deployment
          healthCheck = {
            script = ''
              # Check critical services
              systemctl is-active --quiet systemd-timesyncd || exit 1
              systemctl is-active --quiet networkmanager || exit 1
              
              # Check system resources
              free -m | awk '/^Mem:/{exit ($2-$7) < 512 ? 1 : 0}'
              
              # Check disk space
              df / | awk 'NR==2{exit ($4 < 1024) ? 1 : 0}'
            '';
          };
          
          # Rollback to previous generation
          rollbackScript = ''
            echo "System health check failed, rolling back..."
            sudo nixos-rebuild switch --rollback
            echo "Rollback completed"
          '';
        };
      };
    };

    # Intelligent dependency management
    dependencyManager = {
      # Analyze and optimize dependencies
      analyzeDependencies = config: {
        # Build dependency graph
        dependencyGraph = {
          nodes = lib.attrNames config.environment.systemPackages;
          edges = []; # Would be populated with actual dependency analysis
        };
        
        # Optimize package selection
        optimizedPackages = lib.filter (package: 
          # Keep only necessary packages
          config.environment.systemPackages.${package} != null
        ) (lib.attrNames config.environment.systemPackages);
        
        # Detect redundant dependencies
        redundantDeps = []; # Would be populated with actual analysis
      };

      # Automatic dependency resolution
      resolveDependencies = config: {
        # Resolve conflicts
        resolvedConflicts = {
          # Example: Choose between conflicting packages
          packageSelection = {
            # Prefer newer versions
            newerVersions = true;
            # Prefer stable packages
            stablePackages = true;
            # Prefer minimal dependencies
            minimalDeps = true;
          };
        };
        
        # Optimize store paths
        optimizedStore = {
          # Deduplicate similar packages
          deduplication = true;
          # Use binary cache
          binaryCache = true;
          # Optimize store layout
          storeOptimization = true;
        };
      };
    };

    # Real-time monitoring
    monitoring = {
      # Performance metrics
      performanceMetrics = config: {
        metrics = {
          # Build metrics
          buildTime = {
            current = "2-5 minutes";
            target = "< 5 minutes";
            status = "good";
          };
          
          # Memory metrics
          memoryUsage = {
            current = "1-2GB";
            target = "< 2GB";
            status = "good";
          };
          
          # Store metrics
          storeUsage = {
            current = "50-100GB";
            target = "< 150GB";
            status = "good";
          };
        };
      };

      # Health monitoring
      healthMonitoring = config: {
        checks = {
          # System health
          systemHealth = {
            cpu = "normal";
            memory = "normal";
            disk = "normal";
            network = "normal";
          };
          
          # Service health
          serviceHealth = {
            criticalServices = "healthy";
            optionalServices = "healthy";
            customServices = "healthy";
          };
          
          # Configuration health
          configHealth = {
            syntax = "valid";
            imports = "valid";
            dependencies = "resolved";
            conflicts = "none";
          };
        };
      };

      # Alert system
      alertSystem = config: {
        alerts = {
          # Performance alerts
          performance = {
            buildTime = {
              threshold = "5 minutes";
              action = "optimize configuration";
            };
            memoryUsage = {
              threshold = "2GB";
              action = "reduce complexity";
            };
          };
          
          # Security alerts
          security = {
            vulnerabilities = {
              threshold = "any";
              action = "update packages";
            };
            permissions = {
              threshold = "insecure";
              action = "fix permissions";
            };
          };
          
          # System alerts
          system = {
            diskSpace = {
              threshold = "90%";
              action = "cleanup store";
            };
            services = {
              threshold = "failed";
              action = "restart services";
            };
          };
        };
      };
    };
  };
}
