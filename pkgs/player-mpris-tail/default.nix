{
  pkgs,
  lib,
  fetchurl,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "player-mpris-tail";
  version = "1.0";

  # Bypass Python packaging infrastructure since we're installing
  # a single-file script without setup.py/pyproject.toml
  format = "other";

  # Runtime dependencies available during script execution:
  # - Must be Python packages used by the script
  # - Propagated to dependent environments through PYTHONPATH
  propagatedBuildInputs = [
    dbus-python # MPRIS D-Bus protocol implementation
    pygobject3 # GObject Introspection (GLib/GIO dependencies)
  ];

  # Build-time requirements:
  # wrapGAppsNoGuiHook handles critical environment setup for:
  # - GI_TYPELIB_PATH (GObject introspection typelibs)
  # - GDK_PIXBUF_MODULE_FILE (icon loading)
  # - XDG_DATA_DIRS (shared MPRIS interface definitions)
  buildInputs = [ pkgs.wrapGAppsNoGuiHook ];

  # Immutable script source with content-addressed hash:
  # - Prefer versioned archives over direct git links in production
  # - Verify hash after updates: nix-prefetch-url <url>
  src = fetchurl {
    url = "https://raw.githubusercontent.com/polybar/polybar-scripts/a588bfc1191fe3f25da6b1a789eb017a505ac5bc/polybar-scripts/player-mpris-tail/player-mpris-tail.py";
    sha256 = "1hxqv377ysflh0y4fzxg17n9n34f9ypmkksi3ic5alflvkqx8dhm";
  };

  # Optimization: Skip archive extraction for single-file source
  dontUnpack = true;

  # Phase streamlining for script-only packaging:
  buildPhase = ":"; # No compilation needed
  checkPhase = ":"; # No tests defined in source

  # Install with automatic environment wrapping:
  # - wrapGAppsNoGuiHook injects required paths into wrapper script
  # - Maintain executable permissions (-m755)
  installPhase = ''
    install -Dm755 $src $out/bin/player-mpris-tail
  '';

  # Standard metadata for Nixpkgs compliance
  meta = with lib; {
    description = "Polybar module to tail player MPRIS status";
    homepage = "https://github.com/polybar/polybar-scripts";
    license = licenses.mit;
    maintainers = [ maintainers.cjohnson714 ];
  };
}
