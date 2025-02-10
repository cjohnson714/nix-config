{
  lib,
  stdenv,
  unzip,
  fetchurl,
}:

let
  maple-font =
    {
      pnameSuffix,
      sha256,
      desc,
    }:
    stdenv.mkDerivation rec {
      pname = "MapleMono-${pnameSuffix}";
      version = "7.0-beta36";
      src = fetchurl {
        url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/MapleMono-${pnameSuffix}.zip";
        inherit sha256;
      };

      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      sourceRoot = ".";
      nativeBuildInputs = [ unzip ];
      installPhase = ''
        find . -name '*.ttf'  -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.otf'  -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.woff2' -exec install -Dt $out/share/fonts/woff2 {} \;
      '';

      meta = with lib; {
        homepage = "https://github.com/subframe7536/Maple-font";
        description = ''
          Open source ${desc} font with round corner and ligatures for IDE and command line
        '';
        license = licenses.ofl;
        platforms = platforms.all;
        maintainers = with maintainers; [ oluceps ];
      };
    };

in
{
  TTF = maple-font {
    pnameSuffix = "TTF";
    sha256 = "sha256-J3SjrGq2bka/quqY081xv/aW6ry4wQPqt/x7rkYaU0w=";
    desc = "TrueType";
  };

  NF = maple-font {
    pnameSuffix = "NF";
    sha256 = "sha256-yHqoLdLv9SLbmwA6Y6zYV1crD5Eq2aJea88oyTSrshs=";
    desc = "Nerd Font";
  };

  NFCN = maple-font {
    pnameSuffix = "NF-CN";
    sha256 = "sha256-W5b4jcr6fGaAbasCXCswGMkG/SklCXUbfRcPvZfzsNo=";
    desc = "Nerd Font CN";
  };
}
