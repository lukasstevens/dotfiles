{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.hack
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

  home.file.".latexmkrc".text = "$pdf_previewer = 'open %S';\n";

  programs.zsh.shellAliases = {
    setclip = "pbcopy";
    getclip = "pbpaste";
    ls = "ls -G";
  };

  # Matches the application path used by skhd in darwin/configuration.nix.
  targets.darwin.linkApps.enable = true;
}
