{ pkgs, ... }:
{
  # Kernel configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Kernel parameters
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 15;
      "vm.dirty_background_ratio" = 5;
      "vm.vfs_cache_pressure" = 50;
    };
    
    # Kernel modules
    kernelModules = [
      "vhost_vsock"
      "vhost_net"
      "vhost_i2c"
      "vhost_scsi"
    ];
    
    # Extra kernel modules
    extraModulePackages = with pkgs.linuxPackages; [
      acpi_call
      v4l2loopback
    ];
  };
}
