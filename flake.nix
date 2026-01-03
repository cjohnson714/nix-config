{
  # Base configuration metadata
  description = "My system configuration managed with Nix Flakes";

  # External dependencies and their sources
  inputs = {
    # Core NixOS packages (unstable channel)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Stable NixOS packages (25.11 release)
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs version
    };

    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs version
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      catppuccin,
      zen-browser,
      ...
    }:
    {
      nixosConfigurations = {
        # Main VM configuration definition
        nixos-vm =
          let
            # Shared configuration variables
            username = "integrus";
            system = "x86_64-linux";

            # Arguments passed to all modules
            specialArgs = inputs // {
              inherit username system;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            # System configuration modules
            modules = [
              { nixpkgs.hostPlatform = system; }

              # Host-specific configuration
              ./hosts/nixos-vm

              # User-specific system configuration
              ./users/${username}/nixos.nix

              # Third-party modules
              # chaotic.nixosModules.default # Chaotic-nyx package integration
              catppuccin.nixosModules.catppuccin # System-wide theming

              # Custom package overlays
              {
                nixpkgs.overlays = [
                  (import ./overlays/custom-packages.nix) # Local package customizations
                ];
              }

              # Home Manager integration
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  # Ensure package consistency between system and user environments
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";

                  # Pass special arguments to home-manager
                  extraSpecialArgs = specialArgs;

                  # User-specific home configuration
                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix # User environment config
                      catppuccin.homeModules.catppuccin # User-level theming
                      inputs.zen-browser.homeModules.beta # Zen Browser configuration
                    ];
                  };
                };
              }
            ];
          };

        athena =
          let
            # Shared configuration variables
            username = "integrus";
            system = "x86_64-linux";

            # Arguments passed to all modules
            specialArgs = inputs // {
              inherit username system;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            # System configuration modules
            modules = [

              { nixpkgs.hostPlatform = system; }

              # Host-specific configuration
              ./hosts/athena

              # User-specific system configuration
              ./users/${username}/nixos.nix

              # Third-party modules
              # chaotic.nixosModules.default # Chaotic-nyx package integration
              catppuccin.nixosModules.catppuccin # System-wide theming

              # Custom package overlays
              {
                nixpkgs.overlays = [
                  (import ./overlays/custom-packages.nix) # Local package customizations
                ];
              }

              # Home Manager integration
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  # Ensure package consistency between system and user environments
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";

                  # Pass special arguments to home-manager
                  extraSpecialArgs = specialArgs;

                  # User-specific home configuration
                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix # User environment config
                      catppuccin.homeModules.catppuccin # User-level theming
                      inputs.zen-browser.homeModules.beta # Zen Browser configuration
                    ];
                  };
                };
              }
            ];
          };
      };
    };
}
