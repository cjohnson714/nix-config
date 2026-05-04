{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    services.ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SSH service";
      };
      
      permitRootLogin = lib.mkOption {
        type = lib.types.enum [ "yes" "no" "prohibit-password" "without-password" ];
        default = "no";
        description = "Root login policy";
      };
      
      passwordAuthentication = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable password authentication";
      };
      
      port = lib.mkOption {
        type = lib.types.int;
        default = 22;
        description = "SSH port";
      };
      
      maxAuthTries = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Maximum authentication attempts";
      };
    };
  };

  config = lib.mkIf config.services.ssh.enable {
    # Enable OpenSSH service
    services.openssh = {
      enable = true;
      
      # Security settings
      settings = {
        # Authentication
        PasswordAuthentication = config.services.ssh.passwordAuthentication;
        PermitRootLogin = config.services.ssh.permitRootLogin;
        PubkeyAuthentication = true;
        
        # Connection settings
        Port = config.services.ssh.port;
        MaxAuthTries = config.services.ssh.maxAuthTries;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        
        # Security hardening
        X11Forwarding = false;
        AllowTcpForwarding = false;
        GatewayPorts = "no";
        PermitTunnel = "no";
        
        # Protocol settings
        Protocol = 2;
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
        ];
        MACs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
        ];
        
        # Logging
        LogLevel = "VERBOSE";
        SyslogFacility = "AUTH";
        
        # Access control
        AllowUsers = [ "integrus" ];  # Configure per host
        DenyUsers = [ "root" "guest" "nobody" ];
        
        # Timeouts
        LoginGraceTime = 30;
        
        # Banner
        Banner = "/etc/ssh/banner";
      };
      
      # Host keys
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
      
      # Additional security
      extraConfig = ''
        # Disable weak algorithms
        HostKeyAlgorithms ssh-ed25519,ssh-rsa
        
        # Strict key checking
        StrictModes yes
        
        # Prevent empty passwords
        PermitEmptyPasswords no
        
        # Use PAM
        UsePAM yes
        
        # Limit concurrent sessions
        MaxSessions 10
        MaxStartups 10:30:60
        
        # Disable forwarding
        AllowAgentForwarding no
        PermitUserRC no
        
        # Enable sftp subsystem
        Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
      '';
    };
    
    # Create SSH banner
    environment.etc."ssh/banner".text = ''
      ╔══════════════════════════════════════════════════════════════╗
      ║                    AUTHORIZED ACCESS ONLY                    ║
      ║                                                          ║
      ║  This system is for authorized users only. Individual use   ║
      ║  of this system and/or network without authority from the  ║
      ║  system administrator is prohibited.                       ║
      ║                                                          ║
      ║  Unauthorized access is a violation of applicable laws and   ║
      ║  will be prosecuted to the fullest extent of the law.      ║
      ║                                                          ║
      ║                      All activities are monitored               ║
      ║                    and logged for security purposes           ║
      ╚══════════════════════════════════════════════════════════════╝
    '';
    
    # Firewall configuration for SSH
    networking.firewall = {
      allowedTCPPorts = [ config.services.ssh.port ];
      
      # Rate limiting for SSH
      extraCommands = ''
        # SSH connection rate limiting
        iptables -A INPUT -p tcp --dport ${toString config.services.ssh.port} -m conntrack --ctstate NEW -m recent --set
        iptables -A INPUT -p tcp --dport ${toString config.services.ssh.port} -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
      '';
    };
    
    # Security monitoring for SSH
    services.logrotate.settings.ssh = {
      files = [ "/var/log/auth.log" ];
      frequency = "weekly";
      rotate = 4;
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      postrotate = ''
        /usr/bin/systemctl reload rsyslog > /dev/null 2>&1 || true
      '';
    };
    
    # SSH key management
    programs.ssh = {
      knownHosts = {
        "github.com" = {
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTVDPpxmHzL/2zj7LaWZAtHgeJktUW2ce+iV7QJc4L4Q2RqHLJdAweVNTsY+AP+dx1OJ22Af8DojVTVz+2PCoH0R7EQlqQ3aYbECPHFILJnu2ctQmWjANQzZBT+HdKqJQZITjowdVJ+OkYlWUPc8O7rZn5tJBO6hQ==";
        };
      };
      
      # Client configuration
      extraConfig = ''
        Host *
          ServerAliveInterval 60
          ServerAliveCountMax 3
          ConnectTimeout 30
          StrictHostKeyChecking ask
          VerifyHostKeyDNS yes
          ForwardAgent no
          ForwardX11 no
          ForwardX11Trusted no
          
        Host github.com
          User git
          Hostname github.com
          PreferredAuthentications publickey
          IdentityFile ~/.ssh/id_ed25519
      '';
    };
    
    # User SSH directory setup
    users.users.integrus = {
      openssh.authorizedKeys.keys = [
        # Add your SSH public keys here
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
      ];
      
      # Create SSH directory with proper permissions
      home = "/home/integrus";
      createHome = true;
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "docker" "networkmanager" ];
    };
    
    # Ensure proper permissions for SSH directory
    systemd.tmpfiles.rules = [
      "d /home/integrus/.ssh 0700 integrus users -"
      "d /home/integrus/.ssh/keys 0700 integrus users -"
    ];
  };
}
