{
  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = [ "nvme" ];
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "ext4";
      options = [
        "defaults"
	"noatime"
        "lazytime"
        "commit=120"
        "errors=remount-ro"
        "inode_readahead_blks=32"
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
        "dmask=0022"
        "fmask=0022"
      ];
    };
  };
}
