{
  self,
  ...
}: 
{
  flake = {
    # NixOS configurations
    nixosConfigurations = {
      athena = import ../hosts/athena {
        inherit (self.inputs) nixpkgs home-manager catppuccin zen-browser;
        hostRegistry = import ../hosts/registry.nix;
        lib = import ../lib { inherit (self.inputs) nixpkgs lib; };
      };
      
      nixos-vm = import ../hosts/nixos-vm {
        inherit (self.inputs) nixpkgs home-manager catppuccin zen-browser;
        hostRegistry = import ../hosts/registry.nix;
        lib = import ../lib { inherit (self.inputs) nixpkgs lib; };
      };
    };

    # Home Manager configurations
    homeConfigurations = {
      integrus = import ../users/integrus {
        inherit (self.inputs) nixpkgs home-manager catppuccin zen-browser;
        hostRegistry = import ../hosts/registry.nix;
        lib = import ../lib { inherit (self.inputs) nixpkgs lib; };
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
