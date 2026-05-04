{
  lib,
  flake,
  ...
}: {
  # Library functions
  lib = import ../lib {
    inherit (flake.inputs) nixpkgs lib;
  };
}
