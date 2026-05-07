# Home Manager profile: postmodern-style layout (modules/home/<topic>/default.nix).
{ ... }:
{
  imports = [
    ./core
    ./nix
    ./shell
    ./terminal
    ./cli
    ./theming
    ./files
    ./browser
    ./editors
    ./git
    ./gaming
    ./media
    ./messaging
    ./lftp
    ./gpu
    ./wayland
    ./x11
  ];
}
