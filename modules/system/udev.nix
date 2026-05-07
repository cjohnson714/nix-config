{ pkgs, ... }:
{
  services.udev = {
    packages = [ pkgs.gnome-settings-daemon ];
    extraRules = ''
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
  };
}
