{ pkgs, configHome }:

{
  enable = true;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;
  extraConfig = builtins.readFile (configHome + /vimrc);
  plugins =
    let
      cyp-syntax = pkgs.vimUtils.buildVimPlugin {
        pname = "cyp-syntax";
        version = "2019-11-30";
        src = pkgs.fetchFromGitHub {
          owner = "HE7086";
          repo = "cyp-vim-syntax";
          rev = "a13fc823a490fca1150d36d449594ce0e0a33a79";
          sha256 = "1wadkvn4vkck9c11r2s33747qx3p1iwzrxfxzlchlw0vc5spr2f7";
        };
      };
    in
      with pkgs.vimPlugins; [
        ale
        command-t
        cyp-syntax
        deoplete-nvim
        haskell-vim
        nerdtree
        rust-vim
        { plugin = vimtex; config = "let g:tex_flavor = 'latex'"; }
        vim-nix
      ];
}
