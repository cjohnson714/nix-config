{ ... }:
{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
}
