{ config, lib, pkgs, ... }:

{
    programs.thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
    };

    services.gvfs.enable = true; # Virtual Filesystem support library
    services.tumbler.enable = true; # Thumbnail support for images

    #xdg.configFiles."Thunar/accels.scm".text = ''
    #  ; Thunar accels
    #  (gtk_accel_path "<Actions>/ThunarLocationsActions/LocationButton" "")
    #'';
}