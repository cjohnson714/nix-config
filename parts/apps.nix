{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      apps = {
        disko = {
          type = "app";
          program = "${inputs.disko.packages.${system}.disko}/bin/disko";
        };
        disko-install = {
          type = "app";
          program = "${inputs.disko.packages.${system}.disko-install}/bin/disko-install";
        };
      };
    };
}
