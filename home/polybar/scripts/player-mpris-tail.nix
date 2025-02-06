{
  pkgs,
  lib,
  fetchurl,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "player-mpris-tail";
  version = "1.0";

  propagatedBuildInputs = [
    dbus-python
    pygobject3
  ];
  buildInputs = [ pkgs.wrapGAppsNoGuiHook ]; # Add wrapGAppsNoGuiHook here

  src = fetchurl {
    url = "https://raw.githubusercontent.com/polybar/polybar-scripts/a588bfc1191fe3f25da6b1a789eb017a505ac5bc/polybar-scripts/player-mpris-tail/player-mpris-tail.py";
    sha256 = "1hxqv377ysflh0y4fzxg17n9n34f9ypmkksi3ic5alflvkqx8dhm";
  };

  doUnpack = false;
  unpackPhase = ''
    cp ${src} player-mpris-tail.py
  '';

  preBuild = ''
    cat > setup.py << 'EOF'
    from setuptools import setup
    setup (
      name='player-mpris-tail',
      version='1.0',
      install_requires=['dbus-python', 'pygobject'],
      scripts=['player-mpris-tail.py'],
    )
    EOF
  '';

  postInstall = ''
    wrapProgram $out/bin/player-mpris-tail.py \
      --set GI_TYPELIB_PATH ${pygobject3}/lib/girepository-1.0
  '';

  meta = with lib; {
    description = "Polybar module to tail player MPRIS status";
    homepage = "https://github.com/polybar/polybar-scripts";
    license = licenses.mit;
    maintainers = [ maintainers.yourUsername ]; # Replace with your actual username.
  };
}
