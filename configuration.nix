# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  };
  devices = {
    io = {
      productName = "Surface Go";
      name = "Io";
    };
  };

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./system/boot.nix
      "${home-manager}/nixos"
      ./applications/greetd.nix
      ./system/nfs.nix
      ./system/cleanup.nix
      #./applications/thunar__main.nix
    ];

  hardware.bluetooth = {
    enable = true;
    # This enables A2DP profile connections
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  networking.hostName = "Io"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "au";
    xkb.variant = "";
  };
  services.libinput = {
    # Enable Touchpad functionality
    touchpad = {
      tapping = true;
      tappingDragLock = true;
      naturalScrolling = true;
      tappingButtonMap = "lrm";
    };
    enable = true;
  };

  # Enable multi-touch gesture recognizer
  services.touchegg.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bluser = {
    isNormalUser = true;
    description = "Blank User";
    extraGroups = [ "networkmanager" "wheel" "video" "libvirtd" ];
    packages = with pkgs; [];
  };
  home-manager.backupFileExtension = "backup";
  home-manager.users.bluser = import ./home__bluser.nix;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lm_sensors # Interact with hardware sensors
    nano # Terminal Text Editor
    polkit-kde-agent # Polkit Authentication Agent
  ];

  # Monitor Brightness for Laptops
  programs.light.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable Audio
  # Media Keys was disabled in 24.11, push to handle it via your compositor

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # List services that you want to enable:

  # Battery Power monitoring
  services.upower.enable = true;

  # Enable swaylock authentication
  security.pam.services.swaylock = {};

  # Enable polkit for authentication escalation in GUI applications
  security.polkit.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" && subject.isInGroup("wheel"))
        return polkit.Result.AUTH_ADMIN_KEEP;
    });
  '';

  # Allows for monitor hot swap for Sway
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY="wayland-1";
      DISPLAY = ":0";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.gvfs.enable = true; # Virtual Filesystem support library
  services.tumbler.enable = true; # Thumbnail support for images

  # Bluetooth Management and GUI Applet
  services = {
    blueman = {
      enable = true;
    };
  };

  # Bluetooth Media Controls
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  # VirtualBox Guest Additions
  #virtualisation.virtualbox.guest = true;

  # Enable Virtualisation for QEMU and virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
