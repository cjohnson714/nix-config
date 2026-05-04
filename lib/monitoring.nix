/**
  Monitoring and observability utilities for NixOS configuration.
  Provides comprehensive system monitoring and alerting capabilities.
*/

{ lib, pkgs, ... }:

{
  # Monitoring framework
  monitoring = {
    # System monitoring
    system = {
      # Enable basic system monitoring
      enable = lib.mkDefault true;
      
      # CPU monitoring
      cpu = {
        # Enable CPU frequency monitoring
        tools = with pkgs; [
          cpufrequtils
          lm_sensors
          s-tui
        ];
        
        # Enable temperature monitoring
        services.lm-sensors.enable = lib.mkDefault true;
      };
      
      # Memory monitoring
      memory = {
        # Memory monitoring tools
        tools = with pkgs; [
          htop
          iotop
          smem
          memtester
        ];
        
        # Enable memory monitoring
        boot.kernel.sysctl."vm.swappiness" = lib.mkDefault 10;
      };
      
      # Disk monitoring
      disk = {
        # Disk monitoring tools
        tools = with pkgs; [
          iotop
          hdparm
          smartmontools
          ncdu
        ];
        
        # Enable SMART monitoring
        services.smartd.enable = lib.mkDefault true;
        services.smartd.notifications.mail.enable = lib.mkDefault false;
      };
      
      # Network monitoring
      network = {
        # Network monitoring tools
        tools = with pkgs; [
          nethogs
          iptraf-ng
          nload
          iftop
          mtr
        ];
        
        # Enable network monitoring
        networking.networkmanager.enable = lib.mkDefault true;
      };
      
      # Process monitoring
      process = {
        # Process monitoring tools
        tools = with pkgs; [
          pstree
          lsof
          strace
          ltrace
          perf-tools
        ];
      };
    };
    
    # Performance monitoring
    performance = {
      # Enable performance monitoring
      enable = lib.mkDefault true;
      
      # System performance tools
      tools = with pkgs; [
        linuxPackages.perf
        sysstat
        iotop
        powertop
        tlp
      ];
      
      # Enable sysstat for performance data
      services.sysstat = {
        enable = lib.mkDefault true;
        interval = lib.mkDefault 10;
      };
      
      # Enable power management
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.tlp.enable = lib.mkDefault false;  # Can be enabled per host
      
      # Performance tuning
      boot.kernel.sysctl = {
        "vm.dirty_ratio" = lib.mkDefault 15;
        "vm.dirty_background_ratio" = lib.mkDefault 5;
        "vm.swappiness" = lib.mkDefault 10;
        "net.core.rmem_max" = lib.mkDefault 16777216;
        "net.core.wmem_max" = lib.mkDefault 16777216;
      };
    };
    
    # Logging and auditing
    logging = {
      # Enable comprehensive logging
      enable = lib.mkDefault true;
      
      # System logging
      services.journald = {
        extraConfig = ''
          [Journal]
          Storage=auto
          Compress=yes
          Seal=yes
          RateLimitIntervalSec=30s
          RateLimitBurst=10000
          SystemMaxUse=10G
          SystemKeepFree=2G
          SystemMaxFileSize=100M
          RuntimeMaxUse=10G
          RuntimeKeepFree=2G
          RuntimeMaxFileSize=100M
          MaxLevelSec=info
          ForwardToSyslog=yes
          ForwardToConsole=no
        '';
      };
      
      # Enable auditd
      security.audit.enable = lib.mkDefault true;
      security.auditd.enable = lib.mkDefault true;
      
      # Log rotation
      services.logrotate.enable = lib.mkDefault true;
      services.logrotate.settings = {
        "/var/log/journal/*/*.journal" = {
          rotate = 7;
          daily = true;
          compress = true;
          delaycompress = true;
          missingok = true;
          notifempty = true;
        };
      };
    };
    
    # Alerting and notifications
    alerting = {
      # Enable alerting
      enable = lib.mkDefault false;  # Disabled by default
      
      # System alerts
      system = {
        # Disk space alerts
        diskThreshold = lib.mkDefault 80;  # Percentage
        
        # Memory alerts
        memoryThreshold = lib.mkDefault 90;
        
        # CPU alerts
        cpuThreshold = lib.mkDefault 80;
        
        # Alert script
        alertScript = pkgs.writeShellScript "system-alert" ''
          #!/bin/sh
          # System alerting script
          # Usage: system-alert <type> <threshold> <current_value>
          
          TYPE="$1"
          THRESHOLD="$2"
          CURRENT="$3"
          
          echo "ALERT: $TYPE threshold exceeded: $CURRENT > $THRESHOLD"
          
          # Send notification (customize as needed)
          # notify-send "System Alert" "$TYPE threshold exceeded"
          
          # Log the alert
          logger "System Alert: $TYPE threshold exceeded: $CURRENT > $THRESHOLD"
        '';
      };
    };
    
    # Health checks
    health = {
      # Enable health checks
      enable = lib.mkDefault true;
      
      # System health checks
      checks = {
        # Disk space check
        diskSpace = pkgs.writeShellScript "check-disk-space" ''
          #!/bin/sh
          # Check disk space usage
          THRESHOLD=80
          USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
          
          if [ "$USAGE" -gt "$THRESHOLD" ]; then
            echo "WARNING: Disk usage is ${USAGE}% (threshold: ${THRESHOLD}%)"
            exit 1
          else
            echo "OK: Disk usage is ${USAGE}%"
            exit 0
          fi
        '';
        
        # Memory check
        memory = pkgs.writeShellScript "check-memory" ''
          #!/bin/sh
          # Check memory usage
          THRESHOLD=90
          USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
          
          if [ "$USAGE" -gt "$THRESHOLD" ]; then
            echo "WARNING: Memory usage is ${USAGE}% (threshold: ${THRESHOLD}%)"
            exit 1
          else
            echo "OK: Memory usage is ${USAGE}%"
            exit 0
          fi
        '';
        
        # Load average check
        loadAverage = pkgs.writeShellScript "check-load" ''
          #!/bin/sh
          # Check load average
          THRESHOLD=2.0
          LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
          
          if (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
            echo "WARNING: Load average is $LOAD (threshold: $THRESHOLD)"
            exit 1
          else
            echo "OK: Load average is $LOAD"
            exit 0
          fi
        '';
      };
      
      # Health check service
      service = {
        enable = lib.mkDefault false;
        script = pkgs.writeShellScript "health-checks" ''
          #!/bin/sh
          # Run all health checks
          
          echo "Running system health checks..."
          
          # Disk space check
          ${pkgs.bash}/bin/bash ${monitoring.health.checks.diskSpace}
          
          # Memory check
          ${pkgs.bash}/bin/bash ${monitoring.health.checks.memory}
          
          # Load average check
          ${pkgs.bash}/bin/bash ${monitoring.health.checks.loadAverage}
          
          echo "Health checks completed."
        '';
        
        # Systemd service for health checks
        systemdService = {
          description = "System Health Checks";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash ${monitoring.health.service.script}";
            RemainAfterExit = true;
          };
        };
        
        # Timer for periodic health checks
        timer = {
          description = "Periodic Health Checks";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "hourly";
            Persistent = true;
          };
        };
      };
    };
    
    # Metrics collection
    metrics = {
      # Enable metrics collection
      enable = lib.mkDefault false;  # Disabled by default
      
      # System metrics
      system = {
        # CPU metrics
        cpu = {
          # CPU usage
          usage = pkgs.writeShellScript "cpu-metrics" ''
            #!/bin/sh
            # Collect CPU metrics
            echo "cpu_usage,$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}')"
            echo "cpu_load,$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')"
          '';
          
          # CPU frequency
          frequency = pkgs.writeShellScript "cpu-freq" ''
            #!/bin/sh
            # Collect CPU frequency metrics
            if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
              echo "cpu_freq,$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)"
            fi
          '';
        };
        
        # Memory metrics
        memory = {
          usage = pkgs.writeShellScript "memory-metrics" ''
            #!/bin/sh
            # Collect memory metrics
            free | awk 'NR==2{printf "memory_used,%d\nmemory_total,%d\nmemory_percent,%d\n", $3*1024, $2*1024, $3*100/$2}'
          '';
          
          swap = pkgs.writeShellScript "swap-metrics" ''
            #!/bin/sh
            # Collect swap metrics
            free | awk 'NR==3{printf "swap_used,%d\nswap_total,%d\nswap_percent,%d\n", $3*1024, $2*1024, ($3*100/$2)}'
          '';
        };
        
        # Disk metrics
        disk = {
          usage = pkgs.writeShellScript "disk-metrics" ''
            #!/bin/sh
            # Collect disk metrics
            df -h | awk 'NR>1 && $1!~/tmpfs|dev/ {gsub(/%/, "", $5); printf "disk_%s_used,%d\n", $6, $5}'
          '';
          
          io = pkgs.writeShellScript "disk-io" ''
            #!/bin/sh
            # Collect disk I/O metrics
            iostat -x 1 1 | awk 'NR>4 {printf "disk_%s_read,%d\ndisk_%s_write,%d\n", $1, $4, $1, $5}'
          '';
        };
        
        # Network metrics
        network = {
          traffic = pkgs.writeShellScript "network-metrics" ''
            #!/bin/sh
            # Collect network metrics
            cat /proc/net/dev | awk 'NR>2 {gsub(/:/, "", $1); printf "net_%s_rx,%d\nnet_%s_tx,%d\n", $1, $2, $1, $10}'
          '';
        };
      };
    };
    
    # Apply all monitoring
    enableAll = {
      imports = [
        monitoring.system
        monitoring.performance
        monitoring.logging
        monitoring.health
      ];
    };
  };
}
