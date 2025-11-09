{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    clipboard.register = "unnamedplus";
    colorschemes.nightfox.enable = true;
    colorschemes.nightfox.flavor = "carbonfox";
    lsp = {
      servers = {
        nixd.enable = true;
        # pyright.enable = true;
      };
      keymaps = [
        {
          key = " f";
          lspBufAction = "format";
        }
      ];
    };
    plugins = {
      # configurable plugins
      mini = {
        enable = true;
        modules = {
          basics.enable = true;
          statusline.enable = true;
        };
      };
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
          # python
          kdl
          markdown
        ];
      };
      # non-configurable plugins
      rainbow-delimiters.enable = true;
      lsp-lines.enable = true;
      notify.enable = true;
      lspconfig.enable = true;
    };
  };
}
