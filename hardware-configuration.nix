{
  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = [ "nvme" ];
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "ext4";
      options = [
        "noatime"
        "discard=async"
        "commit=120"
        "errors=remount-ro"
      ];
    };
    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "utf8"
        "shortname=winnt"
        "flush"
      ];
    };
  };
}
