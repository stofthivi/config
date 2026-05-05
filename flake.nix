{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable/";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.home-manager.follows = "";
    nixvim = {
      url = "github:nix-community/nixvim/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      zen-browser,
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hardware-configuration.nix
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          nixvim.nixosModules.nixvim
          ./nixvim.nix
          (
            { pkgs, ... }:
            {
              system.stateVersion = "26.05";
              nix = {
                optimise.automatic = true;
                channel.enable = false;
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
              };

              boot = {
                kernelPackages = pkgs.linuxPackages_latest;
                kernelParams = [
                  "quiet"
                  "loglevel=3"
                  "kernel.printk=3"
                  "rd.systemd.show_status=auto"

                  "nmi_watchdog=0"
                  "nowatchdog"

                  "amd_pstate=active"
                  "amd_pstate.shared_mem=1"

                  "amd_iommu=on"
                  "iommu=pt"

                  "nvme.noacpi=1"
                  "nvme.use_threaded_interrupts=1"

                  "psi=1"
                  "pcie_aspm=force"
                  "amdgpu.sg_display=0"

                  "mitigations=auto"
                  "spec_store_bypass_disable=auto"
                ];
                loader = {
                  timeout = 3;
                  limine = {
                    enable = true;
                    maxGenerations = 5;
                    style.wallpapers = [ ];
                  };
                };
              };
              networking = {
                nftables.enable = true;
                wireless = {
                  iwd = {
                    enable = true;
                    settings.General.EnableNetworkConfiguration = true;
                  };
                };
              };

              hardware.bluetooth.enable = true;
              time.timeZone = "Asia/Yekaterinburg";

              security = {
                sudo-rs.enable = true;
                sudo.enable = false;
                rtkit.enable = true;
              };

              users = {
                defaultUserShell = pkgs.fish;
                users.kei = {
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                  ];
                };
              };

              fonts.packages = with pkgs; [
                nerd-fonts.hack
                font-awesome
                noto-fonts
              ];

              services = {
                dbus.implementation = "broker";
                resolved.enable = true;
                udisks2.enable = true;
                tlp.enable = true;
                playerctld.enable = true;
                gvfs.enable = true;
                pipewire.pulse.enable = true;
              };

              programs = {
                niri.enable = true;
                amnezia-vpn.enable = true;
                waybar.enable = true;
                git.enable = true;
                nano.enable = false;
                # yazi = {
                #   enable = true;
                #   plugins."smart-enter" = pkgs.yaziPlugins.smart-enter;
                #   settings.keymap.manager.prepend_keymap = [
                #     {
                #       on = "l";
                #       run = "plugin smart-enter";
                #     }
                #   ];
                # };
                fish = {
                  enable = true;
                  shellAliases = {
                    x = "sudo";
                    r = "yazi";
                    p = "python";
                    j = "julia";
                    us = "x nixos-rebuild switch";
                    ub = "x nixos-rebuild boot";
                    dl = "yt-dlp -x -o '%(title)s.%(ext)s'";
                    dla = "yt-dlp -x --add-metadata --embed-thumbnail -o '%(title)s.%(ext)s'";
                    um = "udisksctl mount -b /dev/sda1";
                    uu = "udisksctl unmount -b /dev/sda1";
                    pm = "jmtpfs ~/media";
                    pu = "fusermount -u ~/media";
                    playrev = "mpv --play-direction=-";
                  };
                  interactiveShellInit = ''
                    function arev --argument input output
                      ffmpeg -i "$input" -af areverse "$output"
                    end
                  '';
                };
              };

              environment = {
                systemPackages = with pkgs; [
                  # main programs
                  zen-browser.packages."${system}".default
                  telegram-desktop
                  qbittorrent-nox
                  (mpv.override { scripts = [ mpvScripts.mpris ]; })
                  keepassxc
                  kitty
                  zathura
                  imv
                  libreoffice-fresh
                  hunspell
                  hunspellDicts.ru-ru
                  hunspellDicts.en-us
                  # utils
                  zip
                  unzip
                  p7zip
                  mediainfo
                  file
                  wl-clipboard-rs
                  pavucontrol
                  psmisc
                  onagre
                  mako
                  sunsetr
                  swayidle
                  brightnessctl
                  jmtpfs
                  xdg-utils
                  yt-dlp
                  # languages, programming utils
                  python3
                  julia
                  nixd
                  nixfmt
                  # other
                  rose-pine-cursor
                  ffmpeg
                  yazi
                  gimp
                ];
              };
            }
          )
        ];
      };
    };
}
