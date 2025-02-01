{ pkgs, ... }:

# terminals

let
  font = "CaskaydiaCove Nerd Font";
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = font;
      size = 11;
    };
    settings = {
      scrollback_lines = 10000;
      disable_ligatures = "never";
      force_ltr = "no";
      window_margin_width = 5;
    };
    themeFile = "gruvbox-dark-hard";
  };
}
