{
  boot.initrd.availableKernelModules = [ "nvme" ];
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  fileSystems = {

    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "f2fs";
      options = [
        "compress_algorithm=zstd:6"
        "compress_chksum"
        "atgc"
        "gc_merge"
        "lazytime"
        "discard"
      ];
    };

    "/nix/store" = {
      device = "/nix/store";
      fsType = "none";
      options = [ "bind" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "defaults"
        "fmask=0022"
        "dmask=0022"
        "discard"
      ];
    };
  };
}
