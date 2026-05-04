/**
  Builds `nixpkgs.lib.nixosSystem` with shared overlays and Home Manager. Per-machine modules
  are assembled from `hosts/registry.nix` (see `lib/build-hosts.nix`).
*/
inputs:
{
  system ? "x86_64-linux",
  username ? "integrus",
  modules,
  homeImports ? [ ],
}:
let
  inherit (inputs) nixpkgs home-manager catppuccin zen-browser;
  specialArgs = inputs // { inherit username system; };

  sharedModules = [
    ../users/${username}/nixos.nix

    catppuccin.nixosModules.catppuccin

    {
      nixpkgs.overlays = [ (import ../nix/overlays/custom-packages.nix) ];
    }

    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = specialArgs;
        users.${username} = {
          imports =
            [
              ../users/${username}/home.nix
              catppuccin.homeModules.catppuccin
              zen-browser.homeModules.beta
            ]
            ++ homeImports;
        };
      };
    }
  ];
in
nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  modules =
    [
      { nixpkgs.hostPlatform = system; }
      { system.stateVersion = "25.11"; }
    ]
    ++ modules
    ++ sharedModules;
}
