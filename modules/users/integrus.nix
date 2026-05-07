{
  users.users.integrus = {
    openssh.authorizedKeys.keys = [ ];
  };

  # Declared fully in modules/system/; Snowfall would otherwise create a minimal user from homes/.
  snowfallorg.users.integrus.create = false;
}
