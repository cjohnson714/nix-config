{ pkgs, ... }:
{
  # BSPWM autostart applications and services
  environment.systemPackages = with pkgs; [
    # Autostart tools
    dex
  ];

  # Create BSPWM autostart script
  xdg.configFile."bspwm/bspwmrc".source = pkgs.writeText "bspwmrc" ''
    #!/bin/sh

    # Autostart applications
    dex --autostart --environment bspwm

    # Set wallpaper
    feh --bg-scale /usr/share/backgrounds/nixos-wallpaper.png

    # Start panel (if using)
    # polybar &

    # Start notification daemon
    dunst &

    # Start compositor
    picom &

    # Set cursor theme
    xsetroot -cursor_name left_ptr

    # BSPWM settings
    bspc config border_width 2
    bspc config window_gap 12
    bspc config top_padding 0
    bspc config bottom_padding 0
    bspc config left_padding 0
    bspc config right_padding 0

    bspc config normal_border_color "#4c566a"
    bspc config active_border_color "#88c0d0"
    bspc config focused_border_color "#88c0d0"
    bspc config presel_feedback_color "#2e3440"
    bspc config split_ratio 0.50
    bspc config borderless_monocle true
    bspc config gapless_monocle true
    bspc config focus_follows_pointer true

    # Desktop rules
    bspc rule -a Gimp desktop='^8' state=floating follow=on
    bspc rule -a Firefox desktop='^2'
    bspc rule -a mplayer2 state=floating
    bspc rule -a Kupfer.py focus=on
    bspc rule -a Screenkey manage=off
  '';

  # Make bspwmrc executable
  systemd.user.tmpfiles.rules = [
    "C %h/.config/bspwm/bspwmrc 755 - - - -"
  ];
}
