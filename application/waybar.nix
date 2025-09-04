{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      startup-delay = { seconds = 5; };
      mainBar = {
        position = "top";
        height = 35;
        layer = "top";
        spacing = 5;
        modules-left = [ "sway/workspaces"];
        modules-center = [ ];
        modules-right = [ "tray" "clock"];
        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };
        "clock" = {
          format = "{:%Y-%m-%d %H:%M}";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
        min-height: 0;
      }
      window#waybar {
        background-color: #181825;
        color: #cdd6f4;
      }
      window#waybar.hidden {
        opacity: 0.1;
      }
      #tray {
        border-radius: 4px;
        margin: 6px 3px;
        padding: 6px 12px;
        background-color: #1e1e2e;
        color: #181825;
      }
      #workspaces {
        background-color: transparent;
      }
      #cpu {
        background-color: green;
      }
    '';
  };
}
