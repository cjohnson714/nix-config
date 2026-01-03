{ pkgs, inputs, ... }:
{
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    dms-shell = {
      enable = true;
      systemd.enable = true;
      enableClipboard = true;
      enableDynamicTheming = true;
      package = pkgs.dms-shell;
    };
  };
}
