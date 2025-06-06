{
  pkgs,
  ...
}:
# messaging - chat and messaging applications
{
  home.packages = with pkgs; [
    # chat
    ayugram-desktop
    signal-desktop

    (discord.override {
      withOpenASAR = true; # can do this here too
      withVencord = true;
    })

  ];
}
