{ config, pkg, ... }:

{
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    terminal = "kitty";
  };
}
