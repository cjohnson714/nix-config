{
  services.polybar = {
    enable = true;
    script = ''
      # Kill any existing Polybar instances
      pkill -x polybar

      # Wait until Polybar shuts down completely
      while pgrep -x polybar >/dev/null; do sleep 1; done

      # Reset bspwm padding
      bspc config top_padding 0  # Remove top padding
      bspc config bottom_padding 32  # Adjust for bottom bar height

      # Launch Polybar
      polybar bottom &
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
        font-0 = "Roboto:weight=semibold:size=12;2";
        font-1 = "Roboto Mono:weight=semibold:size=12;2";
        font-2 = "Symbols Nerd Font:size=12;2";
        font-3 = "Font Awesome:size=12;2";
        padding-left = "10px";
        padding-right = "10px";
        module-margin = "6px";
        modules-left = "bspwm spacer xwindow";
        modules-center = "";
        modules-right = "pulseaudio spacer tray spacer date";
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

        ws-icon-0 = "I;"; # Terminal
        ws-icon-1 = "II;󰈹"; # Web
        ws-icon-2 = "III;󰨞"; # Graphics (vector/illustration)
        ws-icon-3 = "IV;󰜉"; # Email
        ws-icon-4 = "V;󰝞"; # Code (Programming)
        ws-icon-5 = "VI;󰂉"; # Multimedia (Audio/Video)
        ws-icon-6 = "VII;󰍇"; # Communication (Slack, Teams)
        ws-icon-7 = "VIII;󰥤"; # File Management
        ws-icon-8 = "IX;󰌛"; # Settings (System tools)
        ws-icon-9 = "X;󰻀"; # Miscellaneous (Games or General Use)
        ws-icon-default = "󰇘"; # Default Workspace Icon

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
        label-separator-padding = 2; # Increase padding around separator
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
        date = "%Y-%m-%d";
        time = "%l:%M%P";
        time-alt = "%Y-%m-%d";
        label = "%{T2}%time%%{T-} 󰥔";
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
    };
  };
}
