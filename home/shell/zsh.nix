{
  pkgs,
  config,
  ...
}:
{
  home.file.".zshrc".source = ../../config/zsh/.zshrc;
  home.file.".zshenv".source = ../../config/zsh/.zshenv;
  home.file.".p10k.zsh".source = ../../config/zsh/.p10k.zsh;
}
