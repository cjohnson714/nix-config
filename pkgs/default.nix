{ pkgs }:

{
  player-mpris-tail = pkgs.callPackage ./player-mpris-tail { };
  # Add other packages here in the same way, for example:
  # another-package = pkgs.callPackage ./another-package { };
}
