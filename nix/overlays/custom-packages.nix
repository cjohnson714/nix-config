# Custom package overlays
# This overlay allows adding custom packages or overriding existing ones

final: prev: {
  # Custom packages from the packages directory
  player-mpris-tail = final.callPackage ../../packages/player-mpris-tail {};
  maple-mono = final.callPackage ../../packages/maple-mono {};
  apple-fonts = final.callPackage ../../packages/apple-fonts {};
  
  # Override existing packages
  # Example: neovim = prev.neovim.override { ... };
}
