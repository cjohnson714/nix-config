{ pkgs, ... }:
{
  imports = [
    ./gh
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      credential.helper = "libsecret";
    };
    signing.format = "ssh";
  };
}
