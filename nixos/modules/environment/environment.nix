{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      easyeffects
      fastfetch
      git
      hdparm
      lm_sensors
      libsecret
      ncdu
      nixfmt-rfc-style
      nnn
      ntfs3g
      scrot
      sysstat
      tree
      vim
      wget
      thunar
      nh
      firefox
      warp-terminal
    ];

    variables = {
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
      GDK_USE_XFT = "1";
      QT_XFT = "true";
      XFT_SUBPIXEL = "rgb";
    };

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
