{ ... }:
{
  flake.diskoConfigurations = {
    btrfs-efi-simple = ../disko/schemes/btrfs-efi-simple.nix;
    btrfs-luks-efi-simple = ../disko/schemes/btrfs-luks-efi-simple.nix;
    ext4-efi-simple = ../disko/schemes/ext4-efi-simple.nix;
  };
}
