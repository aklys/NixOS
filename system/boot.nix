{ config, pkgs, ...}:

{
  # To enable boot system, if an ESP partition is already mounted a /boot you can install systemd-boot using
  # sudo bootctl --path=/boot install
  boot.kernelModules = [
    # Virtual Camera Loopback
    "v4l2loopback"
    # Virtual Microphone, built-in
    "snd-aloop"
  ];

  boot.extraModprobeConfig = ''
    # exclusive_caps: Will only show device when streaming
    # card_label: Name of Virtual Camera
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_cap=1 card_label="Virtual Camera"
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"];
  #boot.kernelParams = [ "video=ipu3-cio2" ];
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  #systemd.watchdog.rebootTime = "0";
}