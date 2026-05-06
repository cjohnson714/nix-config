{
  users.users.integrus = {
    openssh.authorizedKeys.keys = [
    ];
  };

  # Declared fully in modules/system.nix; Snowfall would otherwise create a minimal user from homes/.
  snowfallorg.users.integrus.create = false;
}
