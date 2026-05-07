{ ... }:

{
  # Enable profiles for this user/system
  nix-config.profiles = {
    # Desktop environment
    desktop.enable = true;

    # Categories
    cli = true;
    browsers = true;
    media = true;
    gaming = true;
    development = true;
    communication = true;
    wayland = true;
    files = true;
    gpu = true;  # nvidia-system for sakura
  };

  home.stateVersion = "25.05";
}
