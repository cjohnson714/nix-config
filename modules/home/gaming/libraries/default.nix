{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alsa-plugins
    giflib
    glfw
    gst_all_1.gst-plugins-base
    libjpeg
    libxslt
    mpg123
    khronos-ocl-icd-loader
    openal
    liberation_ttf
  ];
}
