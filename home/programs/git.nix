{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    extraConfig = {
      credential.helper = "libsecret";
    };
    # ... Other options ...
  };
}
