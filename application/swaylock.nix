{ config, pkgs, ... }:

# Requires modification to pam in configuration.nix
# security.pam.services.swaylock = {};

{
  home.packages = with pkgs; [
    swaylock-effects
  ];
  xdg.configFile."swaylock/config" = {
    text = ''
      daemonize
      clock
      ignore-empty-password
      screenshots
      effect-blur=7x15
      indicator
      text-color=blue
      fade-in=4
      grace=30
      color=#000000
    '';      
  };
}
