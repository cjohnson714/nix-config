# Custom package overlays
# This overlay allows adding custom packages or overriding existing ones

final: prev: {
  # Add custom packages here
  # Example: my-custom-package = prev.callPackage ../../packages/my-custom-package {};
  
  # Override existing packages
  # Example: neovim = prev.neovim.override { ... };
}
