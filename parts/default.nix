{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  imports = [
    ./formatter.nix
    ./apps.nix
    ./nixos.nix
    ./disko.nix
  ];
}
