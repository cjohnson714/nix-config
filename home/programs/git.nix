{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      credential.helper = "libsecret";
    };
    signing.format = "ssh";
  };
}
