/**
  Example NixOS module fragment for `install/bootstrap.sh` when you pass a **single .nix file**
  as `HOST_MODULE`. It is imported from the generated host `default.nix` alongside the normal
  stack (see bootstrap `write_stacked_host`).
*/
{ pkgs, ... }:
{
  # Example: add a package without forking the whole host tree.
  environment.systemPackages = with pkgs; [ ];
}
