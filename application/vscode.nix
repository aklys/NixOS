{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "[css]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
      };
      "editor.wordWrap" = "on";
      "terminal.external.linuxExec" = "alacritty";
      "workbench.colorTheme" = "Pitch Black";
      "window.menuBarVisibility" = "toggle";
    };
  };
}
