{
  pkgs,
  config,
  ...
}:
{
    services.picom = {
      enable = false;
      backend = "xrender";
      vSync = false;
      shadow = false;
      fade = false;
      settings = {
        blur.enabled = false;
        animations = false;
        dim-inactive = false;
        rounded-corners-rule = [ ];
        paint-on-overlay = false;
        unredir-if-possible = false;
        use-damage = false;
        dithered-present = false;
        inactive-opacity-override = 1.0;
        frame-opacity = 1.0;
        menu-opacity = 1.0;
        popup_menu = { opacity = 1.0; };
        dropdown_menu = { opacity = 1.0; };
        wintypes = {
          tooltip = { fade = false; shadow = false; opacity = 1.0; focus = true; };
          dock = { fade = false; shadow = false; opacity = 1.0; focus = false; };
          dnd = { fade = false; shadow = false; opacity = 1.0; focus = true; };
          popup_menu = { fade = false; shadow = false; opacity = 1.0; focus = true; };
          dropdown_menu = { fade = false; shadow = false; opacity = 1.0; focus = true; };
        };
      };
    };
}
