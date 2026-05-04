# QEMU/KVM guests and similar (virtio, SPICE, QXL).
{ ... }:
{
  services.xserver.videoDrivers = [ "qxl" ];
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
}
