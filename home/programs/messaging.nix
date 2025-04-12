{
  pkgs,
  ...
}:
# messaging - chat and messaging applications
{
  home.packages = with pkgs; [
    # chat
    discord
    ayugram-desktop
    signal-desktop
  ];
}
