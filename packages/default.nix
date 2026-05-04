{ pkgs }:
{

  player-mpris-tail = pkgs.callPackage ./player-mpris-tail { };
  maple-mono = pkgs.callPackage ./maple-mono { };
  apple-fonts = pkgs.callPackage ./apple-fonts { };
}
