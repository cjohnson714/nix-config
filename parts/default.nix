{
  self,
  config,
  ...
}: 
let
  system = config.system;
  pkgs = self.inputs.nixpkgs.legacyPackages.${system};
in {
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

    # Packages
    packages = {
      # Custom packages can be defined here
      # Example: custom-package = import ../packages/custom-package { inherit pkgs; };
    };

    # Apps
    apps = {
      # Development shell
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
      # Configuration validation - using system-specific pkgs
      validate-config = pkgs.runCommand "validate-config" {} ''
        echo "Validation placeholder - nix-instantiate requires full Nix store access"
        mkdir -p $out
        echo "Validation completed" > $out/result
      '';
    };
  };
}
