{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
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
          # notify.enable = true;
        };
      };
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          # pyright.enable = true;
          # ruff.enable = true;
        };
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
          # norg
          kdl
          markdown
        ];
      };
      # non-configurable plugins
      rainbow-delimiters.enable = true;
      # neorg.enable = true;
      lsp-lines.enable = true;
      notify.enable = true;
      # hardtime.enable = true;
    };
  };
}
