{ pkgs, ... }:
{
  # Basic system configuration
  system = {
    stateVersion = "25.11";
    autoUpgrade = {
      enable = false;
    };
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    file
    tree
  ];

  # Basic security
  security.sudo.wheelNeedsPassword = false;
}
