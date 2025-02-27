{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hdparm
    ntfs3g
  ];
  services.resolved.enable = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.page-cluster" = 0;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_writeback_centisecs" = 1500;
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.printk" = "3 3 3 3";
    "kernel.kptr_restrict" = 2;
    "kernel.kexec_load_disabled" = 1;
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
    "fs.xfs.xfssyncd_centisecs" = 10000;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=50M
    MaxFileSec=1day
  '';

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=15s
    DefaultTimeoutStopSec=10s
    DefaultLimitNOFILE=2048:2097152
  '';

  services.timesyncd = {
    enable = true;
    servers = [
      "time.cloudflare.com"
    ];
    fallbackServers = [
      "time.google.com"
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];
  };

  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1024:1048576
  '';

  services.zram-generator = {
    enable = true;
    settings.zram0 = {
      compression-algorithm = "zstd lz4 (type=huge)";
      zram-size = "ram";
      swap-priority = 100;
      fs-type = "swap";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/systemd/coredump 755 root root 3d"
    "w! /sys/module/zswap/parameters/enabled - - - - N"
    "w! /sys/class/rtc/rtc0/max_user_freq - - - - 3072"
    "w! /proc/sys/dev/hpet/max-user-freq  - - - - 3072"
    "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
    "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
  ];

  services.udev.extraRules = ''
    TEST!="/dev/zram0", GOTO="zram_end"
    SYSCTL{vm.swappiness}="150"
    LABEL="zram_end"

    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"

    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
    ATTR{link_power_management_policy}=="*", \
    ATTR{link_power_management_policy}="max_performance"

    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
    ATTR{queue/scheduler}="bfq"

    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="mq-deadline"

    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="none"

    ACTION=="add|bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
    ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
    TEST=="power/control", ATTR{power/control}="auto"

    ACTION=="remove|unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
    ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
    TEST=="power/control", ATTR{power/control}="on"

    DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"

    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
    RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"

    SUBSYSTEM=="block", TEST!="${pkgs.ntfs3g}/bin/ntfs-3g", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"
  '';

  systemd.services."rtkit-daemon".serviceConfig.LogLevelMax = "info";
  systemd.services."user@.service".serviceConfig.Delegate = "cpu cpuset io memory pids";
}
