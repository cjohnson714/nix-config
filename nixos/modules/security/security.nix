{ ... }:
{
  security = {
    polkit.enable = true;
    pam.services.ly.enableGnomeKeyring = true;
    rtkit.enable = true;
  };
}
