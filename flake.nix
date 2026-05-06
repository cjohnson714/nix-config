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
      username = "integrus";
      system = "x86_64-linux";
      specialArgs = inputs // {
        inherit username system;
      };

      sharedSystemModules = [
        { nixpkgs.hostPlatform = system; }

        ./users/${username}/nixos.nix

        inputs.catppuccin.nixosModules.catppuccin

        {
          nixpkgs.overlays = [
            (import ./overlays/custom-packages.nix)
          ];
        }
      ];

    in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      systems.hosts.athena = {
        specialArgs = specialArgs;
        modules = sharedSystemModules;
      };

      systems.hosts.nixos-vm = {
        specialArgs = specialArgs;
        modules = sharedSystemModules;
      };

      homes.modules = [
        inputs.catppuccin.homeModules.catppuccin
        inputs.zen-browser.homeModules.beta
      ];
    };
}
