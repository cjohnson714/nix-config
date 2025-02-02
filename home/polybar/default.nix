{
  pkgs,
  config,
  ...
}:
{

  home.file.".config/polybar/scripts" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };
  services.polybar = {
    enable = true;
    script = ''
      # Terminate already running bar instances
      killall -q polybar

      # Wait until the processes have been shut down
      while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

      # Launch Polybar
      polybar bottom -c ~/.config/polybar/config.ini &
    '';

    settings = {
      "bar/bottom" = {
        width = "100%";
        height = "32px";
        radius = "6px";
        bottom = true;
        background = "\${colors.base}";
        foreground = "\${colors.text}";
        border-size = "2px";
        border-color = "\${colors.crust}";
        font-0 = "SF Pro Rounded:weight=semibold:size=12;2";
        font-1 = "Roboto Mono:weight=semibold:size=12;2";
        font-2 = "Symbols Nerd Font:size=13;2";
        font-3 = "Font Awesome:size=12;2";
        padding-left = "0px";
        padding-right = "10px";
        module-margin = "4px";
        modules-left = "start bspwm xwindow";
        modules-center = "";
        modules-right = "pulseaudio tray date";
        scroll-up = "#bspwm.prev";
        scroll-down = "#bspwm.next";
      };

      "module/spacer" = {
        type = "custom/text";
        format = " ";
      };

      "module/bspwm" = {
        type = "internal/bspwm";
        pin-workspaces = true;
        enable-click = true;
        enable-scroll = false;
        reverse-scroll = false;
        fuzzy-match = true;
        occupied-scroll = true;

        ws-icon-0 = "I;  ";
        ws-icon-1 = "II; 󰈹 ";
        ws-icon-2 = "III;  ";
        ws-icon-3 = "IV;  ";
        ws-icon-4 = "V;  ";
        ws-icon-5 = "VI;  ";
        ws-icon-6 = "VII;  ";
        ws-icon-7 = "VIII;  ";
        ws-icon-8 = "IX; 󱎓 ";
        ws-icon-9 = "X;  ";
        ws-icon-default = " 󰇘 ";

        format = "<label-state> <label-mode>";
        label-focused = " %icon% ";
        label-focused-foreground = "\${colors.green}";
        label-focused-background = "\${colors.surface0}";
        label-focused-underline = "\${colors.yellow}";

        label-occupied = " %icon% ";
        label-occupied-foreground = "\${colors.text}";
        label-occupied-underline = "\${colors.blue}";

        label-empty = " %icon% ";
        label-empty-foreground = "\${colors.overlay1}";

        label-urgent = " %icon% ";
        label-urgent-foreground = "\${colors.red}";
        label-urgent-background = "\${colors.crust}";
        label-urgent-underline = "\${colors.red}";

        label-separator = "|";
        label-separator-padding = 0;
        label-separator-foreground = "\${colors.teal}";
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title%";
        label-foreground = "\${colors.text}";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format = "<label>";
        label = "󰍛 %{T2}%percentage%%{T-}%";
        label-foreground = "\${colors.mauve}";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 5;
        format = "<label>";
        label = "󰍹 %{T2}%used%%{T-}/%{T2}%total%%{T-}";
        label-foreground = "\${colors.pink}";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "ADP1";
        full-at = 99;
        format-charging = "󰂄 %{T2}%capacity%%{T-}%";
        format-discharging = "󰂃 %{T2}%capacity%%{T-}%";
        format-full = "󰁹 %{T2}%capacity%%{T-}%";
        format-alt = "󰂑 No Battery";
        label-foreground = "\${colors.yellow}";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%a %b %e";
        time = "%l:%M %p";
        time-alt = "%Y-%m-%d";
        label = "%date%  %time%  ";
        label-foreground = "\${colors.teal}";
      };

      "module/tray" = {
        type = "internal/tray";
        position = "right"; # Position tray on the bottom right
        icon-size = 16; # Set the icon size of the tray
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = true;
        interval = 5;
        reverse-scroll = false;
        format-volume = "<ramp-volume> <label-volume>";
        label-muted = " muted";
        label-muted-foreground = "#666";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
        click-right = "pavucontrol";
        # click-middle = ;
      };

      "module/start" = {
        type = "custom/text";
        content = "    "; # NixOS logo from Nerd Fonts (nf-linux-nixos)
        content-font = 2; # Ensure this matches the Nerd Font index
        content-foreground = "\${colors.base}"; # Use Nix blue color
        content-background = "\${colors.blue}";
        padding = 0; # Add some padding to make it look clean
        click-left = "~/.config/polybar/scripts/launch_rofi.sh"; # Script to launch app launcher
      };

      "module/player-mpris-tail" = {
        type = "custom/script";
        # The Correct Way to Call the Script:
        exec = "${pkgs.python39}/bin/python3 ~/.config/polybar/scripts/player-mpris-tail.py -f '{icon} {artist} - {title}'";
        tail = true; # Important for real-time updates
        click-left = "${pkgs.python39}/bin/python3 ~/.config/polybar/scripts/player-mpris-tail.py previous"; # Fixed click commands
        click-right = "${pkgs.python39}/bin/python3 ~/.config/polybar/scripts/player-mpris-tail.py next"; # Fixed click commands
        click-middle = "${pkgs.python39}/bin/python3 ~/.config/polybar/scripts/player-mpris-tail.py play-pause"; # Fixed click commands
      };
    };
  };
}
