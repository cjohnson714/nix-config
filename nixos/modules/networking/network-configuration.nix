{ ... }:
{
  services.resolved.enable = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  networking.firewall.enable = true;
  networking.nftables.enable = true;
}
