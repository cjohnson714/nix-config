{ pkgs, ... }:
{
  # User management
  users = {
    # Default user group
    groups = {
      users = {};
    };
    
    # Default user shell
    defaultUserShell = pkgs.bash;
  };
  
  # Security settings for users
  security = {
    # Allow wheel group to use sudo without password
    sudo.wheelNeedsPassword = false;
    
    # Set up PAM
    pam = {
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
      ];
    };
  };
}
