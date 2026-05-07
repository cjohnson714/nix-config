{ config, ... }:
{
  home = {
    username = "integrus";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
