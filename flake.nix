{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      neovim-nightly-overlay
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
              system.stateVersion = "24.11";

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
                  systemd-boot = {
                    enable = true;
                    configurationLimit = 5;
                    editor = false;
                  };
                };
              };

              hardware.bluetooth.enable = true;

              time.timeZone = "Asia/Yekaterinburg";

              systemd.network.wait-online.enable = false;
              networking = {
                useDHCP = false;
                dhcpcd.enable = false;
                useNetworkd = true;
                nftables.enable = true;
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
                hypridle.enable = true;
                playerctld.enable = true;
              };

              users = {
                defaultUserShell = pkgs.fish;
                users.kei = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                };
              };

              fonts.packages = with pkgs; [
                (nerdfonts.override { fonts = [ "Hack" ]; })
                font-awesome
              ];

              programs = {
                gnupg.agent.enable = true;
                adb.enable = true;
                git.enable = true;
                waybar.enable = true;
                nano.enable = false;
                fish = {
                  enable = true;
                  loginShellInit = "test (tty) = /dev/tty1 ;and exec Hyprland";
                  shellAliases = {
                    x = "sudo";
                    r = "ranger";
                    p = "python";
                    dl = "yt-dlp -x -o '%(title)s.%(ext)s'";
                    dla = "yt-dlp -x --add-metadata -o '%(title)s.%(ext)s'";
                    um = "udisksctl mount -b /dev/sda1";
                    uu = "udisksctl unmount -b /dev/sda1";
                    pm = "jmtpfs ~/media";
                    pu = "fusermount -u ~/media";
                  };
                };
                hyprland = {
                  enable = true;
                  xwayland.enable = false;
                };
                nixvim = {
                  enable = true;
                  package = neovim-nightly-overlay.packages.${pkgs.system}.default;
                  defaultEditor = true;
                  viAlias = true;
                  clipboard.register = "unnamedplus";
                  plugins = {
                    mini = {
                      enable = true;
                      modules = {
                        basics.enable = true;
                        statusline.enable = true;
                        pairs.enable = true;
                      };
                    };
                    lsp = {
                      enable = true;
                      servers.nixd.enable = true;
                      keymaps.lspBuf = {
                        " f" = "format";
                      };
                    };
                    treesitter = {
                      enable = true;
                      settings.highlight.enable = true;
                      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                        nix
                        hyprlang
                      ];
                    };
                    rainbow-delimiters.enable = true;
                  };

                };
              };

              environment = {
                sessionVariables.NIXOS_OZONE_WL = "1";
                systemPackages = with pkgs; [
                  # main programs
                  (brave.override { vulkanSupport = true; })
                  telegram-desktop
                  qbittorrent
                  (mpv.override { scripts = [ mpvScripts.mpris ]; })
                  bitwarden-desktop
                  ranger
                  kitty
                  libreoffice-qt6
                  hunspell
                  hunspellDicts.ru-ru
                  hunspellDicts.en-us
                  # utils
                  zathura
                  imv
                  mediainfo
                  file
                  zip
                  unzip
                  p7zip
                  neofetch
                  yt-dlp
                  wl-clipboard
                  libnotify
                  pavucontrol
                  fuzzel
                  mako
                  hyprshade
                  hyprshot
                  brightnessctl
                  jmtpfs
                  xdg-utils
                  # languages, programming utils
                  nixfmt-rfc-style
                  gcc14
                  python313
                  # games, emulators
                  niri
                  webcord
                ];
              };
            }
          )
        ];
      };
    };
}
