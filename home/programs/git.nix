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
      user = {
        name = "cjohnson714";
        email = "cjohnson714@gmail.com";
      };
      credential.helper = "libsecret";
    };
    signing.format = "ssh";
  };
}
