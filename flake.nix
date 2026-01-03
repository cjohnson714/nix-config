{
  description = "My system configuration managed with Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
        nixos-vm =
          let
            username = "integrus";
            system = "x86_64-linux";

            specialArgs = inputs // {
              inherit username system;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            modules = [
              { nixpkgs.hostPlatform = system; }

              ./hosts/nixos-vm

              ./users/${username}/nixos.nix

              catppuccin.nixosModules.catppuccin

              {
                nixpkgs.overlays = [
                  (import ./overlays/custom-packages.nix)
                ];
              }

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";

                  extraSpecialArgs = specialArgs;

                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix
                      catppuccin.homeModules.catppuccin
                      inputs.zen-browser.homeModules.beta
                    ];
                  };
                };
              }
            ];
          };

        athena =
          let
            username = "integrus";
            system = "x86_64-linux";

            specialArgs = inputs // {
              inherit username system;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            modules = [

              { nixpkgs.hostPlatform = system; }

              ./hosts/athena

              ./users/${username}/nixos.nix

              catppuccin.nixosModules.catppuccin

              {
                nixpkgs.overlays = [
                  (import ./overlays/custom-packages.nix)
                ];
              }

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";

                  extraSpecialArgs = specialArgs;

                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix
                      catppuccin.homeModules.catppuccin
                      inputs.zen-browser.homeModules.beta
                    ];
                  };
                };
              }
            ];
          };
      };
    };
}
