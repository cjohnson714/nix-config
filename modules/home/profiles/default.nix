{
  lib,
  ...
}:

with lib;

{
  options.nix-config.profiles = {
    # Core profiles
    base = {
      enable = mkEnableOption "base profile with essential tools" // { default = true; };
    };

    # Category profiles
    cli = mkEnableOption "CLI tools (alacritty, bat, btop, eza, fzf, etc.)";
    browsers = mkEnableOption "web browsers (firefox, floorp, zen-browser)";
    media = mkEnableOption "media tools (mpv, spotify, easyeffects, etc.)";
    gaming = mkEnableOption "gaming tools (mangohud, gamemode)";
    development = mkEnableOption "development tools (git, gh, etc.)";
    communication = mkEnableOption "communication apps (discord, telegram)";
    wayland = mkEnableOption "Wayland utilities (wl-clipboard, grim, slurp, etc.)";
    files = mkEnableOption "file management tools (yazi, fd, ripgrep)";
    gpu = mkEnableOption "GPU-specific tools (nvidia-system)";

    # Shell profile
    desktop = {
      enable = mkEnableOption "desktop shell (niri + noctalia-shell)";
    };
  };
}
