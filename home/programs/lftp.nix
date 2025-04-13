{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    lftp
  ];

  home.file.".config/lftp/rc".source = ../../config/lftp/rc;
}
