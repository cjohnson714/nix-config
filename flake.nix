{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    catppuccin.url = "github:catppuccin/nix";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
        nixos-vm =
          let
            username = "integrus";
            specialArgs = inputs // {
              inherit username;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/nixos-vm
              ./users/${username}/nixos.nix
              chaotic.nixosModules.default
              catppuccin.nixosModules.catppuccin # ✅ Enable Catppuccin system-wide

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users.${username} = {
                  imports = [
                    ./users/${username}/home.nix
                    catppuccin.homeManagerModules.catppuccin # ✅ Enable Catppuccin for Home Manager
                  ];
                };
              }
            ];
          };
      };
    };
}
