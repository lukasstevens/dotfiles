{
  env.TERM = "xterm-256color";
  window = {
    padding = {
      x = 2;
      y = 2;
    };
    decoration = "full";
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
  url = {
    launcher = {
      program = "xdg-open";
      args = [];
    };
    modifiers = "Control";
  };
}
