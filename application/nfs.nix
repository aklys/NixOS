{ pkgs, config, ... }:

{
  fileSystems = {
    "/mnt/InProgress" = {
      device = "172.17.13.110:/mnt/HD/HD_a2/DW_InProgress";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto"];
    };
    "/mnt/Media" = {
      device = "172.17.13.110:/mnt/HD/HD_b2/DW_Media";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto"];
    };
  };
}
