{ config, pkgs, ... }:

{
  services = {
    displayManager.sessionPackages = [ pkgs.sway ];
    displayManager.defaultSession = "sway";
    displayManager.lightdm = {
      enable = true;
      greeters.gtk = {
        enable = true;
        theme.name = "Adwaita";
        extraConfig = ''
          [greeter]
          background = #000000
        '';
      };
    };
  };
}
