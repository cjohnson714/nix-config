{ pkgs, ... }:
{
  users.users.hana = {
    isNormalUser = true;
    description = "hana";
    group = "users";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ];
  };
}
