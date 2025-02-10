{
  lib,
  stdenv,
  fetchurl,
  p7zip,
}:

let
  fonts = [
    {
      name = "SF Pro";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      sha256 = "sha256-IccB0uWWfPCidHYX6sAusuEZX906dVYo8IaqeX7/O88=";
      dir = "SFProFonts";
      pkg = "SF Pro Fonts.pkg";
    }
    {
      name = "SF Mono";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      sha256 = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
      dir = "SFMonoFonts";
      pkg = "SF Mono Fonts.pkg";
    }
    {
      name = "SF Compact";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      sha256 = "sha256-PlraM6SwH8sTxnVBo6Lqt9B6tAZDC//VCPwr/PNcnlk=";
      dir = "SFCompactFonts";
      pkg = "SF Compact Fonts.pkg";
    }
    {
      name = "NY";
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      sha256 = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
      dir = "NYFonts";
      pkg = "NY Fonts.pkg";
    }
    {
      name = "SF Arabic";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
      sha256 = "sha256-J2DGLVArdwEsSVF8LqOS7C1MZH/gYJhckn30jRBRl7k=";
      dir = "SFArabicFonts";
      pkg = "SF Arabic Fonts.pkg";
    }
  ];

  fontsWithDmg = map (
    font:
    font
    // {
      dmg = fetchurl {
        url = font.url;
        sha256 = font.sha256;
      };
    }
  ) fonts;

  extractFont = font: ''
    echo "Extracting ${font.name}..."
    7z x "${font.dmg}"
    pushd "${font.dir}"
      7z x "${font.pkg}"
      7z x "Payload~"
      mv Library/Fonts/* "$out/fontfiles"
    popd
  '';
in
stdenv.mkDerivation {
  pname = "apple-fonts";
  version = "1";

  nativeBuildInputs = [ p7zip ];
  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    set -euo pipefail
    mkdir -p "$out/fontfiles"
    ${lib.concatStringsSep "\n" (map extractFont fontsWithDmg)}
    mkdir -p "$out/usr/share/fonts/OTF" "$out/usr/share/fonts/TTF"
    mv "$out/fontfiles"/*.otf "$out/usr/share/fonts/OTF" || true
    mv "$out/fontfiles"/*.ttf "$out/usr/share/fonts/TTF" || true
    rm -rf "$out/fontfiles"
  '';

  meta = {
    description = "Apple San Francisco, New York, and Arabic fonts";
    homepage = "https://developer.apple.com/fonts/";
    license = lib.licenses.unfree;
  };
}
