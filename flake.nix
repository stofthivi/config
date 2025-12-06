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
              system.stateVersion = "25.11";
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
                useDHCP = false;
                wireless = {
                  iwd = {
                    enable = true;
                    settings.General.EnableNetworkConfiguration = true;
                  };
                };
              };

              hardware.bluetooth.enable = true;
              time.timeZone = "Asia/Yekaterinburg";
              # for wine
              # hardware.graphics.enable32Bit = true;

              security = {
                sudo-rs.enable = true;
                sudo.enable = false;
                rtkit.enable = true;
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

              services = {
                qbittorrent.enable = true;
                dbus.implementation = "broker";
                resolved.enable = true;
		fstrim.enable = false;
                udisks2.enable = true;
                playerctld.enable = true;
                gvfs.enable = true;
                pipewire.pulse.enable = true;
                zapret = {
                  enable = true;
                  # yt
                  whitelist = [
                    "youtube.com"
                    "googlevideo.com"
                    "ytimg.com"
                    "youtu.be"
                  ];
                  params = [
                    "--dpi-desync=fake"
                    "--dpi-desync-fooling=badsum"
                  ];

                  # pixiv
                  #   whitelist = [
                  #     "pixiv.net"
                  #     "www.pixiv.net"
                  #   ];
                  #   params = [
                  #     "--dpi-desync=fake,fakeddisorder"
                  #     "--dpi-desync-ttl=1"
                  #     "--dpi-desync-autottl=-1"
                  #     "--orig-ttl=1"
                  #     "--orig-mod-start=s1"
                  #     "--orig-mod-cutoff=d1"
                  #     "--dpi-desync-split-pos=1"
                  #   ];
                };
              };

              programs = {
                niri.enable = true;
                waybar.enable = true;
                git.enable = true;
                adb.enable = true;
                nano.enable = false;
                yazi = {
                  enable = true;
                  plugins."smart-enter.yazi" = pkgs.yaziPlugins.smart-enter;
                  settings.keymap.manager.prepend_keymap = [
                    {
                      on = "l";
                      run = "plugin smart-enter";
                    }
                  ];
                };
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
                  };
                };
              };

              environment = {
                systemPackages = with pkgs; [
                  # main programs
                  zen-browser.packages."${system}".default
                  telegram-desktop
		  # ungoogled-chromium
                  (mpv.override { scripts = [ mpvScripts.mpris ]; })
                  keepassxc
                  kitty
                  zathura
                  oculante
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
                  nixfmt-rfc-style
                  # other
                  rose-pine-cursor
                  ffmpeg
                  element-desktop
                  zapret
                ];
              };
            }
          )
        ];
      };
    };
}
