{
  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = [ "nvme" ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/70dd1295-4558-4690-a27f-6fe41f515c8b";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/39E2-C4F5";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
}
