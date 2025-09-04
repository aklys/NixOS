{ config, lib, pkgs, ... }:

{
    programs.thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
    };

    # Enable saving of preferences
    # programs.xfconf.enable = true;

    services.gvfs.enable = true; # Virtual Filesystem support library
    services.tumbler.enable = true; # Thumbnail support for images

}