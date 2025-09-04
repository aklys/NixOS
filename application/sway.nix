{ config, lib, pkgs, ... }:

{
  imports = [
    ../applications/swaylock.nix
    ../applications/swaync.nix
  ];
  home.packages = with pkgs; [
    autotiling # Dynamic Tiling System
    rofi-wayland # Application Launcher for Wayland
    grim # Screenshots
    slurp # Screenshots
    copyq # Clip Board Manager for Copy and Paste
    playerctl # Media Control application
    pw-volume # Volume Control
    swayidle # Enable interaction with timeouts and events in Sway
    papirus-icon-theme # Icon theme for KDE applications
    lxappearance # Theming Tool
    libnotify # Library to interact with Notification Daemon

    (pkgs.stdenv.mkDerivation {
    name = "layan-cursors";
    src = pkgs.fetchFromGitHub {
      owner = "cyko-themes";
      repo = "gtk-layan-cursors";
      rev = "master";
      sha256 = "Yp0NnctjTlibceKahKgDDOnQGELQrqCabCOYqrKIJs4=";
    };
    installPhase = ''
      mkdir -p $out/share/icons
      cp -r * $out/share/icons
    '';
    })
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      output = {
        "*" = {
          bg = "#000000 solid_color";
        };
        "eDP-1" = {
          scale = "1.2";
        };
      };
      input = {
        "type:touchpad" = {
          tap = "enabled";
        };
      };
      workspaceOutputAssign = [
        { workspace = "1"; output = "";}
        { workspace = "2"; output = "";}
      ];
      modifier = "Mod4";
      terminal = "kitty";
      window = {
        titlebar = false;
      };
      startup = [
        # This is to help with multiple displays
        {command = "exec sleep 5; systemctl --user start kanshi.service";}
        # This is to enable the dynamic tiling behaviour, it can be told to focus on specific workspaces
        {command = "autotiling";}
        # This is to enable monitoring and interaction with network interfaces
        #{command = "nm-applet";}
        # This is to enable a clipboard manager
        #{command = "copyq";}
        # This is to enable auto lock and sleep and display power off
        {command = "swayidle -w timeout 300 'swaylock -C $HOME/.config/swaylock/config' timeout 1200 'if [ \"$(cat /sys/class/power_supply/ACAD/online)\" -eq 0]; then systemctl suspend; fi' timeout 1800 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' ";}
        # This is to enable the Authentication Agent for Polkit privilege escalation
        {command = "systemctl --user start plasma-polkit-agent"; always = true;}
        # Bluetooth Applet in System Tray
        #{command = "blueman-applet";}
        # Initial Open Applications
        {command = "exec swaymsg -t command \"workspace 1; exec firefox\"";}
        {command = "exec swaymsg -t command \"workspace 2; exec element-desktop; exec discord\"";}
      ];
      bars = [
        {command = "waybar";}
      ];
      keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
          lib.mkOptionDefault {
            # Brightness Keys
            "XF86MonBrightnessDown" = "exec light -U 10";
            "XF86MonBrightnessUp" = "exec light -A 10";

            # Volume Keys
            #"XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
            "XF86AudioRaiseVolume" = "exec 'pw-volume change +1%'";
            #"XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
            "XF86AudioLowerVolume" = "exec 'pw-volume change -1%'";
            #"XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
            "XF86AudioMute" = "exec 'pw-volume mute toggle'";

            # Media Keys
            "XF86AudioPlay" = "exec 'playerctl play-pause'";

            # Application Launcher
            "${modifier}+m" = "exec rofi -show combi -switchers combi -combi-modi 'window,drun' -show-icons -font 'hack 10' -icon-theme 'Papirus'";
            
            # Default Mappings
            "${modifier}+Shift+q" = "kill";

            # Lock Screen
            "${modifier}+l" = "exec swaylock";

            # Notification Center
            "${modifier}+n" = "exec swaync-client -op";

            # Date/Time Notification
            "${modifier}+t" = "exec notify-send \"$(date '+%Y-%m-%d %H:%M:%S')\"";
          };
    };
  };
  services.volnoti.enable = true;
}