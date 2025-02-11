{ pkgs, inputs, ... }:

{
  # ==========================================================================
  #                     Home Manager Main Configuration
  # ==========================================================================
  # Entry point for user-specific environment and package configurations.
  # Imports modular settings from component files in ../../home directory.

  imports = [
    # Core system configuration (environment variables, base packages)
    ../../home/core.nix

    # Application configurations (shared across desktop environments)
    ../../home/programs # General purpose applications
    ../../home/shell # Shell configurations (zsh, bash)

    # Desktop environment components
    ../../home/desktop # Window manager configuration
  ];

  # ==========================================================================
  #                              Git Configuration
  # ==========================================================================
  # Sets global Git credentials and basic version control settings.

  programs.git = {
    userName = "cjohnson714"; # Global Git username
    userEmail = "cjohnson714@gmail.com"; # Associated email for commits
  };
}
