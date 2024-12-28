{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        git-hooks.follows = "";
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "";
        flake-compat.follows = "";
        git-hooks.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        treefmt-nix.follows = "";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      neovim-nightly-overlay,
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
                kernelParams = [ "nowatchdog" ];
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
                hypridle.enable = true;
                playerctld.enable = true;
                resolved.enable = true;
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
                yazi.enable = true;
                adb.enable = true;
                git.enable = true;
                waybar.enable = true;
                nano.enable = false;
                fish = {
                  enable = true;
                  loginShellInit = "test (tty) = /dev/tty1 ;and exec Hyprland";
                  shellAliases = {
                    x = "sudo";
                    r = "yazi";
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
                        python
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
                  brave
                  zen-browser.packages."${system}".default
                  telegram-desktop
                  # qbittorrent
                  qbittorrent-nox
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
                  wl-clipboard-rs
                  pavucontrol
                  fuzzel
                  mako
                  hyprsunset
                  hyprshade
                  hyprshot
                  brightnessctl
                  jmtpfs
                  xdg-utils
                  # languages, programming utils
                  nixfmt-rfc-style
                  # (python313.withPackages (p: with p; [ requests ]))
                  python313
                  rose-pine-cursor
                ];
              };
            }
          )
        ];
      };
    };
}
