{ pkgs, lib, ...}:
{
  env.TERM = "xterm-256color";

  window = {
    padding = {
      x = 2;
      y = 2;
    };
    decorations = lib.mkIf pkgs.stdenv.isLinux "Full";
  };
  
  scrolling = {
    history = 10000;
    multiplier = 3;
  };

  font = {
    size = 12;
    normal = {
      family = "Inconsolata for Powerline";
      style = "Medium";
    };
    bold = {
      family = "Inconsolata for Powerline";
      style = "Bold";
    };
    italic = {
      family = "Inconsolata for Powerline";
      style = "Italic";
    };
  };

  bell = {
    duration = 0;
  };

}
