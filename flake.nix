{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      chaotic,
      ...
    }:
    {
      nixosConfigurations = {
        nixos-vm =
          let
            username = "integrus";
            specialArgs = { inherit username; };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/nixos-vm
              ./users/${username}/nixos.nix
              chaotic.nixosModules.default

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = inputs // specialArgs;
                home-manager.users.${username} = import ./users/${username}/home.nix;
              }
            ];
          };

        /*
          # Standalone home-manager configuration entrypoint
          # Available through 'home-manager --flake .#your-username@your-hostname'
          homeConfigurations = {
            # FIXME replace with your username@hostname
            "integrus@nixos" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
              extraSpecialArgs = {inherit inputs outputs;};
              # > Our main home-manager configuration file <
              modules = [./home-manager/home.nix];
            };
          };
        */
      };
    };
}
