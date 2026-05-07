{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.nix-config.profiles;
in
{
  config = mkIf cfg.cli {
    # Enable all CLI programs
    programs.alacritty.enable = true;
    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.eza.enable = true;
    programs.fzf.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.ssh.enable = true;
    programs.tmux.enable = true;

    # Additional CLI packages
    home.packages = with config.nixpkgs; [
      fuzzel
      graphviz
      libnotify
      wl-gammactl
      xdg-utils
    ];
  };
}
