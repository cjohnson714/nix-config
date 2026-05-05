{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    lftp
  ];

  home.file.".config/lftp/rc".text = builtins.readFile ../../config/lftp/rc;
}
