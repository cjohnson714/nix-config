{ lib, ... }:
{
  boot.supportedFilesystems = [ "bcachefs" ];
  disko.enableConfig = true;

  disko.devices = {
    disk = {
      poolA = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/REPLACE_WITH_DISK_A";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            cryptA = {
              size = "100%";
              content = {
                type = "luks";
                name = "noctalia-crypt-a";
                settings.allowDiscards = true;
                content = {
                  type = "bcachefs";
                  filesystem = "noctalia-pool";
                  label = "group_a.cryptA";
                  extraFormatArgs = [ "--discard" ];
                };
              };
            };
          };
        };
      };

      poolB = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/REPLACE_WITH_DISK_B";
        content = {
          type = "gpt";
          partitions = {
            cryptB = {
              size = "100%";
              content = {
                type = "luks";
                name = "noctalia-crypt-b";
                settings.allowDiscards = true;
                content = {
                  type = "bcachefs";
                  filesystem = "noctalia-pool";
                  label = "group_a.cryptB";
                  extraFormatArgs = [ "--discard" ];
                };
              };
            };
          };
        };
      };
    };

    bcachefs_filesystems.noctalia-pool = {
      type = "bcachefs_filesystem";
      passwordFile = lib.mkDefault "/tmp/noctalia-bcachefs.key";
      extraFormatArgs = [
        "--compression=zstd"
        "--background_compression=zstd"
      ];
      subvolumes = {
        "subvolumes/root" = { mountpoint = "/"; };
        "subvolumes/home" = { mountpoint = "/home"; };
        "subvolumes/nix" = { mountpoint = "/nix"; };
        "subvolumes/persist" = { mountpoint = "/persist"; };
      };
    };
  };
}
