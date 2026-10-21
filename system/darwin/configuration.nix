{ config, pkgs, lib, username, ... }:
let
  spaces = [
    { label = "10_home"; }
    { label = "1_"; }
    { label = "2_"; }
    { label = "3_"; }
    { label = "4_keys"; }
    { label = "5_music"; }
    { label = "6_msg"; }
    { label = "7_mail"; }
    { label = "8_www"; }
    { label = "9_term"; }
  ];

  bgColor = "0xff272935";
  accentColor = "0xff88b6df";

in
{
  imports = [
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
  ];

  documentation.man.enable = true;

  nixpkgs = {
    config.permittedInsecurePackages = [
      "lima-1.2.2"
    ];
    overlays = [
      #(self: super: {
      #  haskell = super.haskell // {
      #    compiler = super.haskell.compiler // {
      #      ghc884 = self.inputs.nur.repos.mpickering.ghc.ghc884;
      #    };
      #  };
      #})
    ];
  };

  # Auto upgrade nix package and the daemon service.
  # nix.package = pkgs.nix;
 
  nix = {
    enable = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" username ];
    };
  };
  ids.uids.nixbld = 3000;
  nix-rosetta-builder.onDemand = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  homebrew = {
    enable = true;
    # Docker Desktop needs its VM; Karabiner needs its privileged installer;
    # Nextcloud's Nix package currently supports Linux only.
    casks = [
      "docker"
      "karabiner-elements"
      "nextcloud"
    ];
    onActivation.cleanup = "none";
  };

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      focus_follows_mouse = "autoraise";
      mouse_follows_focus = "on";
      window_placement = "second_child";
      layout = "bsp";
      window_shadow = "float";
    };
    extraConfig =
      lib.strings.concatImapStrings (i: s: 
        ''
        yabai -m query --spaces --space ${builtins.toString i} || yabai -m space --create
        yabai -m space ${builtins.toString i} --label "${s.label}"
        ''
      ) spaces +
      ''
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="Isabelle" manage=on
      yabai -m rule --add app="Isabelle" title="File Browser" manage=off
      yabai -m rule --add app="Isabelle" title="Search And Replace" manage=off
      '' +
      lib.concatMapStrings (s: lib.concatMapStrings (as: 
        ''
        yabai -m rule --add app="${as.app}" space="${s.label}"
        ''
        ) (s.assigns or [])) spaces;
  };

  services.skhd = {
    enable = true;
    skhdConfig =
      let
        super = "fn";
        mod0 = "shift";
        mod1 = "ctrl";
      in
        ''
        ${super} - k : yabai -m window --focus stack.prev || yabai -m window --focus north || yabai -m display --focus north
        ${super} - j : yabai -m window --focus stack.next || yabai -m window --focus south || yabai -m display --focus south
        ${super} - h : yabai -m window --focus west || yabai -m display --focus west
        ${super} - l : yabai -m window --focus east || yabai -m display --focus east 
        ${super} + ${mod0} - k : yabai -m window --swap north
        ${super} + ${mod0} - j : yabai -m window --swap south
        ${super} + ${mod0} - h : yabai -m window --swap west
        ${super} + ${mod0} - l : yabai -m window --swap east
        ${super} + ${mod1} - k : yabai -m space --display north 
        ${super} + ${mod1} - j : yabai -m space --display south
        ${super} + ${mod1} - h : yabai -m space --display west
        ${super} + ${mod1} - l : yabai -m space --display east
        ${super} - return : open -na "/Users/${username}/Applications/Home Manager Apps/Alacritty.app"
        '' +
        lib.strings.concatImapStrings (i: s:
          ''
          ${super} - ${builtins.toString (i - 1)} : yabai -m space --focus "${s.label}"
          ${super} + ${mod0} - ${builtins.toString (i - 1)} : yabai -m window --space "${s.label}"
          ''
          ) spaces;
  };
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.primaryUser = username;
}
