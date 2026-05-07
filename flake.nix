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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      specialArgs = inputs // {
        inherit system;
      };

      sharedSystemModules = import ./nix/shared-system-modules.nix {
        inherit inputs system;
      };
    in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
      };

      snowfall = {
        meta = {
          name = "nix-config";
          title = "NixOS configuration";
        };
      };

      overlays = [
        (import ./overlays/custom-packages.nix)
      ];

      systems.modules.nixos = sharedSystemModules;

      systems.hosts = {
        sakura.specialArgs = specialArgs;
        nixos-vm.specialArgs = specialArgs;
      };

      homes.modules = with inputs; [
        catppuccin.homeModules.catppuccin
        zen-browser.homeModules.beta
      ];
    };
}
