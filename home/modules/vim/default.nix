{ config, pkgs, ... }:

{
  xdg.configFile."nvim/colors/base16-scheme.vim".source = (config.scheme {
    templateRepo = builtins.fetchTarball {
      name = "base16-vim";
      url = https://github.com/tinted-theming/base16-vim/archive/79d4fb4575b6e9fab785c44557529240c0b7093a.tar.gz;
      sha256 = "15qkn0gkcshzi9lvm70ycx7flikc3c4g2c7sdyk0nvjxmiifxxvm";
    };
  });

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withRuby = true;
    extraConfig = builtins.readFile ./vimrc + ''
      let base16colorspace=256
      try
          colorscheme base16-scheme
      catch
          echom "colorscheme base16-scheme not found."
      endtry
      '';
    plugins = with pkgs.vimPlugins; [
      { plugin = vim-nix; type = "viml"; }
      { plugin = nerdtree; type = "viml"; }
      { plugin = command-t; type = "lua"; }
      nvim-cmp
      cmp-nvim-lsp
      { plugin = ale; type = "viml"; }
      {
        plugin = vimtex;
        type = "viml";
        config = ''
          let g:tex_flavor = 'latex'
          let g:maplocalleader = '<'
          '';
      }
    ];
  };
}
