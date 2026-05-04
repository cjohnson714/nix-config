/**
  Advanced security and compliance utilities for NixOS configuration.
  Provides security hardening, compliance checking, and audit capabilities.
*/
{ lib, pkgs, ... }: {
  # Security framework
  security = {
    # Security hardening
    hardening = {
      # Kernel hardening
      kernel = {
        # Enable kernel hardening
        enable = true;
        
        # Kernel parameters for security
        sysctl = {
          # Network security
          "net.ipv4.ip_forward" = 0;
          "net.ipv4.conf.all.send_redirects" = 0;
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.all.accept_source_route" = 0;
          "net.ipv4.conf.all.log_martians" = 1;
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv4.tcp_max_syn_backlog" = 2048;
          "net.ipv4.tcp_synack_retries" = 2;
          "net.ipv4.tcp_syn_retries" = 5;
          
          # File system security
          "fs.protected_regular" = 1;
          "fs.protected_fifos" = 1;
          "fs.suid_dumpable" = 0;
          
          # Memory security
          "vm.swappiness" = 10;
          "vm.dirty_ratio" = 15;
          "vm.dirty_background_ratio" = 5;
          
          # Core dumps
          "kernel.core_pattern" = "|/bin/false";
          "kernel.suid_dumpable" = 0;
          
          # Exec shield
          "kernel.exec-shield" = 1;
          "kernel.randomize_va_space" = 2;
          
          # ptrace restrictions
          "kernel.yama.ptrace_scope" = 1;
        };
        
        # Kernel modules to disable
        disabledModules = [
          "cramfs"
          "freevxfs"
          "jffs2"
          "hfs"
          "hfsplus"
          "squashfs"
          "udf"
          "vfat"
        ];
        
        # Blacklisted kernel modules
        blacklistModules = [
          "dccp"
          "sctp"
          "rds"
          "tipc"
        ];
      };
      
      # User space hardening
      userspace = {
        # Disable core dumps
        disableCoreDumps = true;
        
        # Restrict file permissions
        umask = "027";
        
        # Enable ASLR
        enableASLR = true;
        
        # Enable stack protection
        enableStackProtection = true;
        
        # Enable RELRO
        enableRELRO = true;
        
        # Enable PIE
        enablePIE = true;
      };
      
      # Network hardening
      network = {
        # Enable firewall
        enableFirewall = true;
        
        # Disable unnecessary services
        disableUnnecessaryServices = true;
        
        # Enable intrusion detection
        enableIntrusionDetection = false;
        
        # Enable network monitoring
        enableNetworkMonitoring = false;
      };
    };

    # Compliance checking
    compliance = {
      # CIS Benchmarks
      cisBenchmarks = {
        # CIS Controls
        controls = {
          # Inventory and Control of Enterprise Assets
          assetManagement = true;
          
          # Inventory and Control of Software Assets
          softwareManagement = true;
          
          # Data Protection
          dataProtection = true;
          
          # Secure Configuration of Enterprise Assets and Software
          secureConfiguration = true;
          
          # Account Management
          accountManagement = true;
          
          # Access Control Management
          accessControl = true;
          
          # Continuous Vulnerability Management
          vulnerabilityManagement = true;
          
          # Audit Log Management
          auditLogManagement = true;
        };
        
        # CIS Benchmarks validation
        validation = {
          # Check CIS compliance
          checkCompliance = true;
          
          # Generate compliance report
          generateReport = true;
          
          # Compliance level
          level = "1";  # Options: "1", "2", "3"
        };
      };
      
      # PCI DSS compliance
      pciDSS = {
        # Enable PCI DSS compliance
        enable = false;
        
        # PCI DSS requirements
        requirements = {
          # Install and maintain a firewall configuration
          firewall = true;
          
          # Do not use vendor-supplied defaults for system passwords
          passwordPolicy = true;
          
          # Protect stored cardholder data
          dataProtection = true;
          
          # Encrypt transmission of cardholder data
          encryption = true;
          
          # Use and regularly update anti-virus software
          antivirus = false;  # Not applicable to NixOS
          
          # Develop and maintain secure systems and applications
          secureDevelopment = true;
          
          # Restrict access to cardholder data by business need to know
          accessControl = true;
          
          # Identify and authenticate access to system components
          authentication = true;
          
          # Restrict physical access to cardholder data
          physicalAccess = true;
          
          # Track and monitor all access to network resources and cardholder data
          monitoring = true;
          
          # Regularly test security systems and processes
          testing = true;
          
          # Maintain an information security policy
          policy = true;
        };
      };
      
      # GDPR compliance
      gdpr = {
        # Enable GDPR compliance
        enable = false;
        
        # GDPR requirements
        requirements = {
          # Lawfulness, fairness and transparency
          transparency = true;
          
          # Purpose limitation
          purposeLimitation = true;
          
          # Data minimization
          dataMinimization = true;
          
          # Accuracy
          accuracy = true;
          
          # Storage limitation
          storageLimitation = true;
          
          # Integrity and confidentiality
          integrityConfidentiality = true;
          
          # Accountability
          accountability = true;
        };
      };
    };

    # Security monitoring
    monitoring = {
      # Log monitoring
      logs = {
        # Enable log monitoring
        enable = true;
        
        # Log retention
        retention = {
          days = 90;
          maxSize = "1G";
        };
        
        # Log rotation
        rotation = {
          enable = true;
          frequency = "daily";
          keep = 30;
        };
        
        # Log analysis
        analysis = {
          enable = true;
          tools = ["logwatch" "fail2ban"];
        };
      };
      
      # Intrusion detection
      intrusionDetection = {
        # Enable intrusion detection
        enable = false;
        
        # IDS tools
        tools = ["aide" "tripwire"];
        
        # Scan frequency
        scanFrequency = "daily";
        
        # Alert configuration
        alerts = {
          email = false;
          syslog = true;
        };
      };
      
      # Security auditing
      auditing = {
        # Enable security auditing
        enable = true;
        
        # Audit rules
        rules = [
          # System calls
          "-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=4294967295 -k exec"
          "-a always,exit -F arch=b32 -S execve -F auid>=1000 -F auid!=4294967295 -k exec"
          
          # File access
          "-w /etc/passwd -p wa -k identity"
          "-w /etc/group -p wa -k identity"
          "-w /etc/gshadow -p wa -k identity"
          "-w /etc/shadow -p wa -k identity"
          "-w /etc/sudoers -p wa -k identity"
          
          # System changes
          "-w /etc/hosts -p wa -k system"
          "-w /etc/sysconfig -p wa -k system"
          
          # Network configuration
          "-w /etc/iptables -p wa -k network"
        ];
        
        # Audit log storage
        storage = {
          path = "/var/log/audit";
          maxSize = "100M";
          maxFiles = 10;
        };
      };
    };

    # Access control
    accessControl = {
      # User management
      users = {
        # Password policy
        passwordPolicy = {
          # Minimum password length
          minLength = 12;
          
          # Password complexity
          requireUppercase = true;
          requireLowercase = true;
          requireNumbers = true;
          requireSpecialChars = true;
          
          # Password history
          history = 5;
          
          # Password expiration
          maxAge = 90;
          minAge = 1;
          warnAge = 7;
          
          # Account lockout
          lockoutThreshold = 5;
          lockoutDuration = 900;
        };
        
        # User groups
        groups = {
          # Administrative groups
          admin = ["wheel" "sudo"];
          
          # Service groups
          service = ["systemd-journal" "systemd-network"];
          
          # User groups
          user = ["users" "audio" "video"];
        };
        
        # SSH access control
        ssh = {
          # Enable SSH key management
          enableKeyManagement = true;
          
          # SSH key requirements
          keyRequirements = {
            minKeySize = 2048;
            allowedTypes = ["rsa" "ed25519"];
            maxAge = 365;
          };
          
          # SSH access control
          accessControl = {
            # Allow only specific users
            allowedUsers = [];
            
            # Deny specific users
            deniedUsers = ["root"];
            
            # Allow only specific groups
            allowedGroups = [];
            
            # Deny specific groups
            deniedGroups = [];
          };
        };
      };
      
      # File permissions
      filePermissions = {
        # Default file permissions
        defaultFileMode = "0644";
        defaultDirMode = "0755";
        
        # Sensitive file permissions
        sensitiveFiles = {
          "/etc/shadow" = "000";
          "/etc/gshadow" = "000";
          "/etc/passwd" = "0644";
          "/etc/group" = "0644";
          "/etc/ssh/sshd_config" = "0600";
          "/etc/sudoers" = "0440";
        };
        
        # Executable permissions
        executableFiles = {
          "/usr/bin/sudo" = "4755";
          "/usr/bin/passwd" = "4755";
          "/usr/bin/su" = "4755";
        };
      };
      
      # Service permissions
      servicePermissions = {
        # Service user management
        serviceUsers = {
          # Create dedicated users for services
          createUsers = true;
          
          # Service user defaults
          defaults = {
            shell = "/sbin/nologin";
            home = "/var/empty";
            createHome = false;
            isSystemUser = true;
            group = "nogroup";
          };
        };
        
        # Service file permissions
        serviceFiles = {
          # Configuration files
          configs = "0600";
          
          # Executable files
          executables = "0755";
          
          # Log files
          logs = "0640";
        };
      };
    };

    # Cryptography
    cryptography = {
      # Disk encryption
      diskEncryption = {
        # Enable disk encryption
        enable = false;
        
        # Encryption method
        method = "luks2";
        
        # Encryption settings
        settings = {
          # Cipher
          cipher = "aes-xts-plain64";
          
          # Key size
          keySize = 512;
          
          # Hash
          hash = "sha512";
          
          # Iterations
          iterations = 500000;
        };
        
        # Encrypted volumes
        volumes = [];
      };
      
      # File encryption
      fileEncryption = {
        # Enable file encryption
        enable = false;
        
        # Encryption tool
        tool = "gpg";
        
        # Default recipient
        defaultRecipient = "";
        
        # Encrypted directories
        directories = [];
      };
      
      # Network encryption
      networkEncryption = {
        # Enable network encryption
        enable = true;
        
        # VPN configuration
        vpn = {
          # Enable VPN
          enable = false;
          
          # VPN type
          type = "wireguard";  # Options: "wireguard", "openvpn", "ipsec"
          
          # VPN settings
          settings = {
            # Server configuration
            server = "";
            port = 51820;
            protocol = "udp";
            
            # Encryption settings
            cipher = "aes256-gcm";
            auth = "sha256";
          };
        };
        
        # TLS configuration
        tls = {
          # Enable TLS
          enable = true;
          
          # TLS version
          minVersion = "1.2";
          
          # Cipher suites
          cipherSuites = [
            "TLS_AES_256_GCM_SHA384"
            "TLS_CHACHA20_POLY1305_SHA256"
            "TLS_AES_128_GCM_SHA256"
          ];
        };
      };
    };

    # Security policies
    policies = {
      # Security policy framework
      framework = {
        # Enable security policies
        enable = true;
        
        # Policy enforcement
        enforcement = {
          # Strict mode
          strict = false;
          
          # Violation handling
          violations = {
            # Log violations
            log = true;
            
            # Alert on violations
            alert = true;
            
            # Block on violations
            block = false;
          };
        };
      };
      
      # Security policies
      policies = {
        # Password policy
        password = {
          # Enable password policy
          enable = true;
          
          # Policy settings
          settings = {
            minLength = 12;
            requireUppercase = true;
            requireLowercase = true;
            requireNumbers = true;
            requireSpecialChars = true;
            history = 5;
            maxAge = 90;
          };
        };
        
        # Access policy
        access = {
          # Enable access policy
          enable = true;
          
          # Policy settings
          settings = {
            # Time-based access
            timeBased = false;
            
            # Location-based access
            locationBased = false;
            
            # Device-based access
            deviceBased = false;
          };
        };
        
        # Data policy
        data = {
          # Enable data policy
          enable = true;
          
          # Policy settings
          settings = {
            # Data classification
            classification = ["public" "internal" "confidential" "secret"];
            
            # Data retention
            retention = {
              public = 365;
              internal = 180;
              confidential = 90;
              secret = 30;
            };
            
            # Data encryption
            encryption = {
              atRest = true;
              inTransit = true;
            };
          };
        };
      };
    };
  };
}
