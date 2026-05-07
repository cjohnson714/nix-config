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

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      username = "hana";
      system = "x86_64-linux";
      specialArgs = inputs // {
        inherit username system;
      };

      sharedSystemModules = import ./nix/shared-system-modules.nix {
        inherit inputs username system;
      };
    in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        meta = {
          name = "nix-config";
          title = "NixOS configuration";
        };
      };

      systems.hosts.sakura = {
        inherit specialArgs;
        modules = sharedSystemModules;
      };

      systems.hosts.nixos-vm = {
        inherit specialArgs;
        modules = sharedSystemModules;
      };

      homes.modules = with inputs; [
        catppuccin.homeModules.catppuccin
        zen-browser.homeModules.beta
      ];
    };
}
