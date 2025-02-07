{ pkgs, neovim-nightly-overlay, ... }:
{
  programs.nixvim = {
    enable = true;
    package = neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    clipboard.register = "unnamedplus";
    colorschemes.nightfox.enable = true;
    colorschemes.nightfox.flavor = "carbonfox";
    plugins = {
      # configurable plugins
      mini = {
        enable = true;
        modules = {
          basics.enable = true;
          statusline.enable = true;
          # pairs.enable = true;
          # notify.enable = true;
        };
      };
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          pyright.enable = true;
          ruff.enable = true;
        };
        keymaps.lspBuf = {
          "gf" = "format";
        };
      };
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
          python
          hyprlang
	  norg
        ];
      };
      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            preset = "enter";
          };
        };
      };

      # non-configurable plugins
      rainbow-delimiters.enable = true;
      neorg.enable = true;
      lsp-lines.enable = true;
      notify.enable = true;
      hardtime.enable = true;

      # plugins for later
      # noice.enable = true;
      # leap.enable = true;
    };
  };
}
