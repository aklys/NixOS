{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
    export PATH="$PATH:/mnt/InProgress/Regular_Files/Scripts/Linux"
    '';
  };
}