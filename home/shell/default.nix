{ config, ... }:
let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in
{
  imports = [
    ./zsh.nix
    ./common.nix
    ./terminals.nix
  ];

  home.sessionVariables = {
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    WINEPREFIX = d + "/wine";

    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    DELTA_PAGER = "less -R";

    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  home.shellAliases = {
    k = "kubectl";
  };
}
