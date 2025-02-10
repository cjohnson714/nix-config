self: super:
let
  customPkgs = import ../pkgs { pkgs = super; };
in
customPkgs
