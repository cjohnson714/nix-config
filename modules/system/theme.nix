{ ... }:
{
  catppuccin = {
    enable = true;
    accent = "mauve";
    flavor = "mocha";
    tty.enable = true;
    cache.enable = true;
  };

  services.printing.enable = true;
}
