{ pkgs, ... }:
{
  # BSPWM keybindings and input configuration
  environment.systemPackages = with pkgs; [
    # Keybinding tools
    sxhkd
    xbindkeys
    xclip
    # Additional tools for enhanced keybindings
    playerctl
    brightnessctl
    alsa-utils
    pamixer
  ];

  # SXHKD configuration for new users (in /etc/skel)
  # Note: User-specific keybindings should be configured in Home Manager
  environment.etc."skel/.config/sxhkd/sxhkdrc".text = ''
    # =============================================================================
    # BSPWM Keybindings Configuration
    # =============================================================================

    # =============================================================================
    # APPLICATION LAUNCHERS
    # =============================================================================
    
    # Terminal
    super + Return
        alacritty
    
    # Application launcher
    super + d
        rofi -show drun
    
    # File manager
    super + e
        thunar
    
    # Web browser
    super + w
        firefox
    
    # Text editor
    super + n
        nvim
    
    # System monitor
    super + i
        htop
    
    # =============================================================================
    # WINDOW MANAGEMENT
    # =============================================================================
    
    # Window focus
    super + {Left,Down,Up,Right}
        bspc node -f {west,south,north,east}
    
    # Window swap
    super + shift + {Left,Down,Up,Right}
        bspc node -s {west,south,north,east}
    
    # Window preselect
    super + ctrl + {Left,Down,Up,Right}
        bspc node -p {west,south,north,east}
    
    # Window resize
    super + alt + {Left,Down,Up,Right}
        bspc node -z {left --right,bottom --up,top --down,right --left}
    
    # Close window
    super + {_,shift + } q
        bspc node -{c,k}
    
    # Toggle fullscreen
    super + f
        bspc node -t "~"{fullscreen,tiled}
    
    # Toggle floating
    super + s
        bspc node -t "~"{floating,tiled}
    
    # Toggle pseudo tiling
    super + p
        bspc node -t "~"{pseudo_tiled,tiled}
    
    # =============================================================================
    # DESKTOP/WORKSPACE MANAGEMENT
    # =============================================================================
    
    # Focus desktop
    super + {1-9,0}
        bspc desktop -f ^{1-9,10}
    
    # Send node to desktop
    super + shift + {1-9,0}
        bspc node -d ^{1-9,10}
    
    # Send node to desktop and follow
    super + ctrl + shift + {1-9,0}
        bspc node -d ^{1-9,10} --follow
    
    # Create new desktop
    super + ctrl + {minus,equal}
        bspc monitor -a {remove,add}
    
    # =============================================================================
    # WINDOW STATES AND LAYOUTS
    # =============================================================================
    
    # Set window state
    super + {t,shift + t,s,shift + s}
        bspc node -t {tiled,pseudo_tiled,floating,fullscreen}
    
    # Set node flags
    super + ctrl + {m,x,y,z}
        bspc node -g {marked,locked,sticky,private}
    
    # Focus parent/child node
    super + {grave,Tab}
        bspc node -f {parent,child}
    
    # =============================================================================
    # SYSTEM CONTROLS
    # =============================================================================
    
    # Restart/Quit BSPWM
    super + shift + {r,q}
        bspc {wm -r,quit}
    
    # Reload SXHKD
    super + Escape
        pkill -USR1 -x sxhkd
    
    # =============================================================================
    # MULTIMEDIA CONTROLS
    # =============================================================================
    
    # Volume controls
    {XF86AudioRaiseVolume,XF86AudioLowerVolume,XF86AudioMute}
        {pamixer --increase 5,pamixer --decrease 5,pamixer --toggle-mute}
    
    # Brightness controls
    {XF86MonBrightnessUp,XF86MonBrightnessDown}
        {brightnessctl set +5%,brightnessctl set 5%-}
    
    # Media player controls
    {XF86AudioPlay,XF86AudioPause,XF86AudioNext,XF86AudioPrev}
        {playerctl play-pause,playerctl pause,playerctl next,playerctl previous}
    
    # =============================================================================
    # SCREEN CONTROLS
    # =============================================================================
    
    # Screenshot
    {Print,shift + Print,ctrl + Print}
        {maim -s ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png,maim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png,maim -i ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png}
    
    # =============================================================================
    # ADVANCED WINDOW OPERATIONS
    # =============================================================================
    
    # Balance nodes
    super + b
        bspc node @/ -B
    
    # Equalize nodes
    super + equal
        bspc node @/ -E
    
    # Circulate leaves
    super + {comma,period}
        bspc node @/ -C {backward,forward}
    
    # Rotate tree
    super + r
        bspc node @/ -R 90
    
    # Flip tree
    super + shift + r
        bspc node @/ -F horizontal
    
    # =============================================================================
    # GAP CONTROL
    # =============================================================================
    
    # Increase/decrease gaps
    super + {minus,equal}
        bspc config -d window_gap $(($(bspc config -d window_gap) {+,-} 2))
    
    # Reset gaps
    super + shift + {minus,equal}
        bspc config -d window_gap {0,12}
    
    # =============================================================================
    # APPLICATION-SPECIFIC BINDINGS
    # =============================================================================
    
    # Firefox specific
    super + ctrl + w
        firefox --private-window
    
    # Terminal specific
    super + ctrl + Return
        alacritty --class floating
    
    # =============================================================================
    # MOUSE BINDINGS (handled by BSPWM config)
    # =============================================================================
  '';

  # X11 key configuration
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = [
      "caps:ctrl_modifier"
      "grp:alt_shift_toggle"
      "terminate:ctrl_alt_bksp"
    ];
  };

  # Mouse configuration
  services.xserver.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
      middleEmulation = false;
    };
    touchpad = {
      accelProfile = "adaptive";
      accelSpeed = "0.5";
      tapping = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
    };
  };
}
