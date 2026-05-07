{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      font-awesome
      vista-fonts
      material-design-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.symbols-only
      roboto
      roboto-mono
      inter
      maple-mono.TTF
      maple-mono.NF
      maple-mono.NFCN
      apple-fonts
    ];

    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = [
        "New York"
        "Noto Serif"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "SF Pro"
        "Noto Sans"
        "Noto Color Emoji"
      ];
      monospace = [
        "Maple Mono NF CN"
        "Caskaydia Cove Nerd Font"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };

    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      antialias = true;
    };
  };
}
