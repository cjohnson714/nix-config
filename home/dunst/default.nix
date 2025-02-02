{
  pkgs,
  config,
  ...
}:
{
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.gruvbox-plus-icons; # Or however the package is named
      name = "Gruvbox-Plus-Dark"; # The actual name of the theme
      size = "32x32"; # Or your preferred size. Adjust if needed.
    };
    settings = {
      global = {
        monitor = 0;
        follow = "none";
        width = "(0, 500)"; # Corrected
        height = "(0, 500)"; # Corrected
        origin = "top-right";
        offset = "(10, 10)";
        scale = 0;
        notification_limit = 20;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 0;
        progress_bar_corners = "all";
        icon_corner_radius = 0;
        icon_corners = "all";
        indicate_hidden = true;
        transparency = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 5;
        frame_color = "#a6e3a1";
        gap_size = 10;
        separator_color = "auto";
        sort = true;
        # idle_threshold = 120;
        font = "CaskaydiaCove Nerd Font Mono SemiBold 16px";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        enable_recursive_icon_lookup = true;
        icon_theme = "Gruvbox-Plus-Dark";
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 128;
        icon_path = "/usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/";
        sticky_history = true;
        history_length = 20;
        dmenu = "/usr/bin/dmenu -p dunst:";
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
        corners = "all";
        ignore_dbusclose = false;
        # layer = "top";
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = [ "close_current" ];
        mouse_middle_click = [
          "do_action"
          "close_current"
        ];
        mouse_right_click = [ "close_all" ];
      };

      experimental = {
        per_monitor_dpi = true;
      };

      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
        # default_icon = "/path/to/icon";
      };

      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
        override_pause_level = 30;
        # default_icon = "/path/to/icon";
      };

      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        timeout = 0;
        override_pause_level = 60;
        # default_icon = "/path/to/icon";
      };

      # Example rule (uncomment and adapt as needed)
      # ignore = {
      #   summary = "foobar";
      #   skip_display = true;
      # };

      # Add other rules here as needed.
    };
  };
}
