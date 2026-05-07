{ pkgs, ... }:
{
  home.packages = [ pkgs.lftp ];

  home.file.".config/lftp/rc".source = ./files/lftp/rc;
}
