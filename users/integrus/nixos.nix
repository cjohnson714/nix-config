{

  # NixOS User Configuration - integrus
  # Configuration specific to the 'integrus' user.

  users.users.integrus = {
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJx3Sk20pLL1b2PPKZey2oTyioODrErq83xG78YpFBoj suzi@suzi" # Example key (commented out)
    ]; # Authorized SSH keys for integrus
  };
}