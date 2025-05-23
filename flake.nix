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
          nixvim.nixosModules.nixvim
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./hardware-configuration.nix
          (
            { pkgs, ... }:
            {
              imports = [
                (import ./nixvim.nix { inherit pkgs; })
              ];
              system.stateVersion = "25.05";
              system.rebuild.enableNg = true;

              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                optimise.automatic = true;
                channel.enable = false;
              };

              boot = {
                kernelPackages = pkgs.linuxPackages_latest;
                loader = {
                  timeout = 3;
                  limine = {
                    enable = true;
                    maxGenerations = 5;
                    style.wallpapers = [ ];
                  };
                };
              };

              hardware.bluetooth.enable = true;

              time.timeZone = "Asia/Yekaterinburg";

              networking = {
                useDHCP = false;
                wireless = {
                  iwd = {
                    enable = true;
                    settings = {
                      General = {
                        EnableNetworkConfiguration = true;
                      };
                    };
                  };
                };
              };

              security = {
                sudo-rs.enable = true;
                sudo.enable = false;
                rtkit.enable = true;
              };

              services = {
                dbus.implementation = "broker";
                pipewire.pulse.enable = true;
                udisks2.enable = true;
                seatd.enable = true;
                gvfs.enable = true;
                playerctld.enable = true;
                resolved.enable = true;
                zapret = {
                  enable = true;
                  whitelist = [
                    "youtube.com"
                    "googlevideo.com"
                    "prostovpn.org"
                    "ytimg.com"
                    "youtu.be"
                  ];
                  params = [
                    "--dpi-desync=fake"
                    "--dpi-desync-fooling=badsum"
                  ];
                };
              };

              users = {
                defaultUserShell = pkgs.fish;
                users.kei = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                };
              };

              fonts.packages = with pkgs; [
                nerd-fonts.hack
                font-awesome
                noto-fonts
              ];

              programs = {
                yazi = {
                  enable = true;
                  plugins = {
                    "smart-enter.yazi" = pkgs.yaziPlugins.smart-enter;
                  };
                  settings.keymap.manager.prepend_keymap = [
                      {on = "l"; run = "plugin smart-enter";}
                    ];
                };
                niri.enable = true;
                adb.enable = true;
                git.enable = true;
                waybar.enable = true;
                nano.enable = false;
                fish = {
                  enable = true;
                  loginShellInit = "test (tty) = /dev/tty1 ;and exec niri --session";
                  shellAliases = {
                    x = "sudo";
                    r = "yazi";
                    p = "python";
                    us = "x nixos-rebuild switch";
                    ub = "x nixos-rebuild boot";
                    dl = "yt-dlp -x -o '%(title)s.%(ext)s'";
                    dla = "yt-dlp -x --add-metadata -o '%(title)s.%(ext)s'";
                    um = "udisksctl mount -b /dev/sda1";
                    uu = "udisksctl unmount -b /dev/sda1";
                    pm = "jmtpfs ~/media";
                    pu = "fusermount -u ~/media";
                  };
                };
              };

              environment = {
                sessionVariables.NIXOS_OZONE_WL = "1";
                systemPackages = with pkgs; [
                  # main programs
                  zen-browser.packages."${system}".default
                  brave
                  telegram-desktop
                  qbittorrent-nox
                  (mpv.override { scripts = [ mpvScripts.mpris ]; })
                  bitwarden-desktop
                  kitty
                  libreoffice-qt6
                  hunspell
                  hunspellDicts.ru-ru
                  hunspellDicts.en-us
                  # utils
                  zathura
                  oculante
                  mediainfo
                  file
                  zip
                  unzip
                  p7zip
                  wl-clipboard-rs
                  pavucontrol
                  psmisc
                  onagre
                  mako
                  wlsunset
                  swayidle
                  brightnessctl
                  jmtpfs
                  xdg-utils
                  yt-dlp
                  # languages, programming utils
                  nixfmt-rfc-style
                  python313
                  # other
                  rose-pine-cursor
                  ffmpeg
                ];
              };
            }
          )
        ];
      };
    };
}
