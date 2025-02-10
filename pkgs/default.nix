{ pkgs }:

{
  player-mpris-tail = pkgs.callPackage ./player-mpris-tail { };
  maple-mono = pkgs.callPackage ./maple-mono { };
  apple-fonts = pkgs.callPackage ./apple-fonts { };
  # Add other packages here in the same way, for example:
  # another-package = pkgs.callPackage ./another-package { };
}
