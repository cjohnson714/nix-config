/**
  GPT: EFI (vfat /boot) + LUKS1 volume with btrfs (single @root subvolume → /).

  - `device` placeholder is replaced by `install/lib/render_disko.py`.
  - `passwordFile` defaults to `/tmp/disko-luks-password` (created by `install/bootstrap.sh` before disko runs).
  - `settings.allowDiscards` uses `lib.mkDefault` so hosts can override (e.g. disable on paranoid SSD setups).

  After first boot, consider moving unlock secrets to initrd (`boot.initrd.luks.devices.*`) or a
  keyfile on `/boot` — disko + `nixos-generate-config` usually wire LUKS for initrd, but review
  generated `hardware-configuration.nix` and `boot.initrd` on real hardware.
*/
{ lib, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/CHANGE_ME";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = lib.mkDefault "/tmp/disko-luks-password";
                settings = {
                  allowDiscards = lib.mkDefault true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
