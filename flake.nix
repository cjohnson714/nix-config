{
  # Base configuration metadata
  description = "My system configuration managed with Nix Flakes";

  # External dependencies and their sources
  inputs = {
    # Core NixOS packages (unstable channel)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Community package collection
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Theme customization framework
    catppuccin.url = "github:catppuccin/nix";

    # User environment management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs version
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      chaotic,
      catppuccin,
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
            inherit system specialArgs;

            # System configuration modules
            modules = [
              # Host-specific configuration
              ./hosts/nixos-vm

              # User-specific system configuration
              ./users/${username}/nixos.nix

              # Third-party modules
              chaotic.nixosModules.default # Chaotic-nyx package integration
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

                  # Pass special arguments to home-manager
                  extraSpecialArgs = specialArgs;

                  # User-specific home configuration
                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix # User environment config
                      catppuccin.homeManagerModules.catppuccin # User-level theming
                    ];
                  };
                };
              }
            ];
          };
      };
    };
}
