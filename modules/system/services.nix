{ pkgs, ... }:
{
  services = {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      package = pkgs.scx.full;
    };

    timesyncd = {
      enable = true;
      servers = [ "time.cloudflare.com" ];
      fallbackServers = [
        "time.google.com"
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };

    zram-generator = {
      enable = true;
      settings.zram0 = {
        compression-algorithm = "zstd lz4 (type=huge)";
        zram-size = "ram";
        swap-priority = 100;
        fs-type = "swap";
      };
    };

    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };

    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=50M
      MaxFileSec=1day
    '';

    power-profiles-daemon.enable = true;
    dbus.packages = [ pkgs.gcr ];
    udisks2.enable = true;
    geoclue2.enable = true;

    gnome.gnome-keyring.enable = true;

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    bpftune.enable = true;
  };
}
