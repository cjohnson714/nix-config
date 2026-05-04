{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    services.firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall service";
      };
      
      defaultPolicy = lib.mkOption {
        type = lib.types.enum [ "accept" "drop" "reject" ];
        default = "drop";
        description = "Default firewall policy";
      };
      
      logging = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall logging";
      };
      
      rateLimit = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable connection rate limiting";
      };
      
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of allowed TCP ports";
      };
      
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of allowed UDP ports";
      };
      
      trustedInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of trusted network interfaces";
      };
    };
  };

  config = lib.mkIf config.services.firewall.enable {
    # Enable nftables firewall
    networking.nftables.enable = true;
    
    # Firewall configuration
    networking.firewall = {
      enable = true;
      allowPing = false;  # Disable ping responses
      
      # Allowed ports (configure per host)
      allowedTCPPorts = config.services.firewall.allowedTCPPorts;
      allowedUDPPorts = config.services.firewall.allowedUDPPorts;
      
      # Trusted interfaces (localhost, VPN, etc.)
      trustedInterfaces = config.services.firewall.trustedInterfaces ++ [ "lo" ];
      
      # Connection tracking
      connectionTrackingModule = true;
    };
    
    # Advanced nftables rules
    networking.nftables.ruleset = ''
      # Define tables and chains
      table inet filter {
        # Input chain
        chain input {
          type filter hook input priority 0; policy ${config.services.firewall.defaultPolicy};
          
          # Allow established and related connections
          ct state established,related accept
          
          # Allow loopback traffic
          iifname lo accept
          
          # Allow trusted interfaces
          ${lib.concatMapStringsSep "\n" (iface: "iifname ${iface} accept") config.services.firewall.trustedInterfaces}
          
          # Allow SSH (if enabled)
          ${lib.optionalString (lib.elem 22 config.services.firewall.allowedTCPPorts) ''
            tcp dport 22 ct state new limit rate 5/minute accept
          ''}
          
          # Allow specific ports
          ${lib.concatMapStringsSep "\n" (port: "tcp dport ${toString port} accept") config.services.firewall.allowedTCPPorts}
          ${lib.concatMapStringsSep "\n" (port: "udp dport ${toString port} accept") config.services.firewall.allowedUDPPorts}
          
          # Rate limiting for new connections
          ${lib.optionalString config.services.firewall.rateLimit ''
            # Limit new connections per IP
            ip protocol tcp ct state new limit rate 10/minute accept
            ip protocol udp ct state new limit rate 10/minute accept
          ''}
          
          # Logging
          ${lib.optionalString config.services.firewall.logging ''
            # Log dropped packets
            log prefix "nft-drop: " flags all
          ''}
          
          # Drop everything else
          drop
        }
        
        # Forward chain
        chain forward {
          type filter hook forward priority 0; policy drop;
          
          # Allow established and related connections
          ct state established,related accept
          
          # Allow forwarding on trusted interfaces
          ${lib.concatMapStringsSep "\n" (iface: "iifname ${iface} accept") config.services.firewall.trustedInterfaces}
          
          # Log dropped packets
          ${lib.optionalString config.services.firewall.logging ''
            log prefix "nft-forward-drop: " flags all
          ''}
          
          drop
        }
        
        # Output chain
        chain output {
          type filter hook output priority 0; policy accept;
          
          # Allow all outgoing traffic
          accept
        }
      }
      
      # NAT table for masquerading (if needed)
      ${lib.optionalString config.networking.nat.enable ''
        table ip nat {
          chain prerouting {
            type nat hook prerouting priority 0; policy accept;
            accept
          }
          
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            
            # Masquerade for outgoing traffic
            oifname != lo masquerade
          }
        }
      ''}
    '';
    
    # Additional security hardening
    boot.kernel.sysctl = {
      # Network security
      "net.ipv4.ip_forward" = lib.mkDefault 0;
      "net.ipv4.conf.all.send_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.default.send_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.all.accept_source_route" = lib.mkDefault 0;
      "net.ipv4.conf.default.accept_source_route" = lib.mkDefault 0;
      "net.ipv4.conf.all.accept_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.default.accept_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.all.secure_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.default.secure_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.all.log_martians" = lib.mkDefault 1;
      "net.ipv4.conf.default.log_martians" = lib.mkDefault 1;
      
      # TCP hardening
      "net.ipv4.tcp_syncookies" = lib.mkDefault 1;
      "net.ipv4.tcp_max_syn_backlog" = lib.mkDefault 2048;
      "net.ipv4.tcp_synack_retries" = lib.mkDefault 2;
      "net.ipv4.tcp_syn_retries" = lib.mkDefault 5;
      "net.ipv4.tcp_rfc1337" = lib.mkDefault 1;
      
      # IPv6 security
      "net.ipv6.conf.all.accept_ra" = lib.mkDefault 0;
      "net.ipv6.conf.default.accept_ra" = lib.mkDefault 0;
      "net.ipv6.conf.all.accept_redirects" = lib.mkDefault 0;
      "net.ipv6.conf.default.accept_redirects" = lib.mkDefault 0;
    };
    
    # Firewall monitoring and logging
    services.logrotate.settings.nftables = {
      files = [ "/var/log/nftables.log" ];
      frequency = "weekly";
      rotate = 4;
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      postrotate = ''
        /usr/bin/systemctl reload nftables > /dev/null 2>&1 || true
      '';
    };
    
    # Install firewall management tools
    environment.systemPackages = with pkgs; [
      nftables
      iptables
      conntrack-tools
      nettools
      lsof
    ];
    
    # Systemd service for firewall status monitoring
    systemd.services.firewall-monitor = {
      description = "Firewall Status Monitor";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "nftables.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "firewall-monitor" ''
          #!/bin/sh
          # Monitor firewall status
          
          echo "Firewall Status Monitor"
          echo "======================"
          
          # Check nftables status
          if systemctl is-active --quiet nftables; then
            echo "✓ nftables service is running"
          else
            echo "✗ nftables service is not running"
          fi
          
          # Show active rules
          echo ""
          echo "Active firewall rules:"
          nft list ruleset | head -20
          
          # Show connection tracking
          echo ""
          echo "Connection tracking statistics:"
          conntrack -L | wc -l
          echo "active connections"
        '';
        RemainAfterExit = true;
      };
    };
    
    # Timer for periodic firewall monitoring
    systemd.timers.firewall-monitor = {
      description = "Periodic Firewall Monitor";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
