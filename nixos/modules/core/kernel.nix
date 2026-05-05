{ pkgs, lib, ... }:
{
  # Enhanced kernel configuration with security hardening
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Security-hardened kernel parameters
    kernel.sysctl = {
      # Memory management
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 15;
      "vm.dirty_background_ratio" = 5;
      "vm.vfs_cache_pressure" = 50;
      
      # Security hardening
      "kernel.randomize_va_space" = 2;  # Full ASLR
      "kernel.dmesg_restrict" = 1;      # Restrict dmesg
      "kernel.kptr_restrict" = 2;       # Restrict kernel pointers
      "kernel.perf_event_paranoid" = 2; # Restrict perf events
      "kernel.kexec_load_disabled" = 1; # Disable kexec
      "kernel.apparmor_restrict_unprivileged_userns_complain" = 1;
      
      # Network security
      "net.ipv4.ip_forward" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_max_syn_backlog" = 2048;
      "net.ipv4.tcp_synack_retries" = 2;
      "net.ipv4.tcp_syn_retries" = 5;
      "net.ipv4.tcp_rfc1337" = 1;
      
      # IPv6 security
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.default.accept_ra" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      
      # File system security
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;
      
      # Core dump security
      "kernel.core_pattern" = "|/bin/false";
      "kernel.core_uses_pid" = 1;
      
      # Executable space protection
      "kernel.exec-shield" = 1;
      
      # Yama security module
      "kernel.yama.ptrace_scope" = 1;
      
      # BPF JIT hardening
      "net.core.bpf_jit_harden" = 2;
    };
    
    # Security kernel modules
    kernelModules = [
      # Virtualization modules
      "vhost_vsock"
      "vhost_net"
      "vhost_i2c"
      "vhost_scsi"
      
      # Security modules
      "apparmor"
      "yama"
      "integrity"
      "tun"
      
      # Hardware support
      "kvm_intel"
      "kvm_amd"
      
      # File systems
      "btrfs"
      "ext4"
      "vfat"
      "ntfs"
      
      # Network
      "8021q"
      "bonding"
      "bridge"
      "tun"
    ];
    
    # Extra kernel modules for security and functionality
    extraModulePackages = with pkgs.linuxPackages; [
      # Security modules
      acpi_call
      v4l2loopback
      
      # Hardware support
      broadcom_sta
      rtl8812au
      rtl8723bs
      
      # File systems
      zfs
      exfat
      ntfs3g
    ];
    
    # Kernel command line parameters for security
    kernelParams = [
      # Security hardening
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "random.trust_cpu=on"
      "random.trust_bootloader=on"
      
      # Page table isolation
      "pti=on"
      
      # Retpoline for Spectre mitigation
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      
      # Meltdown mitigation
      "mds=full"
      
      # Other mitigations
      "tsx=off"
      "l1tf=full"
      "nosmt=force"
      
      # Boot parameters
      "quiet"
      "splash"
      "loglevel=3"
    ];
    
    # Boot loader security
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;  # Disable boot editor
        configurationLimit = 50;
      };
      
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      
      timeout = 5;
    };
    
    # Secure boot support
    lanzaboote = {
      enable = false;  # Can be enabled per host
      pkiBundle = "/etc/secureboot";
    };
    
    # Kernel crash dumps (disabled for security)
    kernel.sysctl."kernel.panic" = 10;
    kernel.sysctl."kernel.panic_on_oops" = 1;
  };
  
  # Security modules
  security = {
    # AppArmor
    apparmor = {
      enable = true;
      enforceByDefault = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };
    
    # SELinux (alternative to AppArmor)
    selinux = {
      enable = false;  # Can be enabled per host
    };
    
    # LSM (Linux Security Modules)
    lockKernelModules = true;
    protectKernelImage = true;
    
    # Unprivileged user namespaces
    unprivilegedUsernamespaces = false;
    
    # Virtualization security
    virtualisation = {
      libvirtd = {
        enable = false;  # Can be enabled per host
      };
    };
  };
  
  # Hardware security
  hardware = {
    # CPU microcode updates
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
    
    # Graphics security
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    
    # TPM support
    tpm2 = {
      enable = false;  # Can be enabled per host
    };
  };
}
