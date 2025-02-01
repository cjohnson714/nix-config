{
  pkgs,
  config,
  ...
}:
{
  home.file.".zshrc".source = ./.zshrc;
  home.file.".zshenv".source = ./.zshenv;
  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
