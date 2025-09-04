{ config, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd 'sway' -t --time-format '%Y-%m-%d %H:%M:%S' -r --asterisks --theme 'time=cyan'";
        user = "greeter";
      };
      watchers = {
        lid-switch = {
          command = "systemctl suspend";
          events = [ "lid-switch" ];
        };
        power-button = {
          command = "systemctl suspend";
          events = [ "power-button" ];
        };
      };
    };
  };
}
