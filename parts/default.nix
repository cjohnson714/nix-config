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

    # Packages
    packages = {
      # Custom packages can be defined here
      # Example: custom-package = import ../packages/custom-package { inherit (self.inputs) nixpkgs; };
    };

    # Apps
    apps = {
      # Development shell
      dev = {
        type = "app";
        program = "${self.inputs.nixpkgs.legacyPackages.${system}.bash}/bin/bash";
      };
    };

    # Dev shells
    devShells = {
      default = self.inputs.nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with self.inputs.nixpkgs.legacyPackages.${system}; [
          nixFlakes
          git
          alejandra
          nixfmt
        ];
      };
    };

    # Checks
    checks = {
      # Configuration validation
      validate-config = self.inputs.nixpkgs.legacyPackages.${system}.runCommand "validate-config" {} ''
        ${self.inputs.nixpkgs.legacyPackages.${system}.nix}/bin/nix-instantiate --eval --strict --show-trace ${./.}
      '';
    };
  };
}
