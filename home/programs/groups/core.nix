# Core user environment: dotfiles, shell-adjacent tools, identity.
{ ... }:
{
  imports = [
    ./common.nix
    ./xdg.nix
    ./git.nix
  ];
}
