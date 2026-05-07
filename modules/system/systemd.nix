{ ... }:
{
  systemd = {
    settings.Manager = {
      DefaultTimeoutStartSec = "15s";
      DefaultTimeoutStopSec = "10s";
      DefaultLimitNOFILE = "2048:2097152";
    };

    user.extraConfig = ''
      DefaultLimitNOFILE=1024:1048576
    '';

    tmpfiles.rules = [
      "d /var/lib/systemd/coredump 755 root root 3d"
      "w! /sys/module/zswap/parameters/enabled - - - - N"
      "w! /sys/class/rtc/rtc0/max_user_freq - - - - 3072"
      "w! /proc/sys/dev/hpet/max-user-freq  - - - - 3072"
      "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
      "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    ];

    services = {
      "rtkit-daemon".serviceConfig.LogLevelMax = "info";
      "user@.service".serviceConfig.Delegate = "cpu cpuset io memory pids";
    };

    oomd.enable = true;
  };
}
