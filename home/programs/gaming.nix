{
  pkgs,
  ...
}:
# gaming - play games
{
  home.packages = with pkgs; [
    # game engines
    steam

    # necessary dependencies
    alsa-plugins
    giflib
    glfw
    gst_all_1.gst-plugins-base
    libjpeg
    libxslt
    mpg123
    khronos-ocl-icd-loader
    openal
    proton-ge-custom
    protontricks
    liberation_ttf
    wine
    winetricks
    vulkan-tools
  ];
}
