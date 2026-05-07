{ ... }:
{
  services.xsettingsd = {
    enable = true;
    settings = {
      "Xft/Antialias" = true;
      "Xft/Hinting" = true;
      "Xft/HintStyle" = "hintslight";
      "Xft/DPI" = 98304;
      "Xft/lcdfilter" = "lcddefault";
      "Xft/RGBA" = "rgb";
      "EnableInputFeedbackSounds" = false;
      "Net/EnableEventSounds" = true;
    };
  };
}
