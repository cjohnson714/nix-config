{
  self,
  ...
}: 
let
  inherit (self.inputs) nixpkgs nixpkgs-stable home-manager catppuccin zen-browser;
  lib = nixpkgs.lib;
  flakeRoot = self.outPath;

  # Build hosts using the proper mk-nixos infrastructure
  nixosConfigurations = import ../lib/build-hosts.nix {
    inherit inputs lib flakeRoot;
  };

  inputs = {
    inherit nixpkgs nixpkgs-stable home-manager catppuccin zen-browser;
  };
in 
{
  flake = {
    inherit nixosConfigurations;

    # Home Manager configurations - reuse nixosConfigurations settings
    homeConfigurations = {
      integrus = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; username = "integrus"; };
        modules = [
          ../users/integrus/home.nix
          catppuccin.homeModules.catppuccin
          zen-browser.homeModules.beta
        ];
      };
    };
  };
  
  # Per-system outputs (packages, apps, devShells, checks)
  perSystem = { system, pkgs, ... }: {
    # Packages
    packages = {
      # Custom packages can be defined here
    };

    # Apps
    apps = {
      dev = {
        type = "app";
        program = "${pkgs.bash}/bin/bash";
      };
    };

    # Dev shells
    devShells = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixFlakes
          git
          alejandra
          nixfmt
        ];
      };
    };

    # Checks
    checks = {
      validate-config = pkgs.runCommand "validate-config" {} ''
        echo "Validation placeholder"
        mkdir -p $out
        echo "Validation completed" > $out/result
      '';
    };
  };
}
