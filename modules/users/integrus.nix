{
  users.users.hana = {
    openssh.authorizedKeys.keys = [ ];
  };

  # Declared fully in modules/system/; Snowfall would otherwise create a minimal user from homes/.
  snowfallorg.users.hana.create = false;
}
