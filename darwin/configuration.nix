{ config, pkgs, lib, ... }:
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

  hostPlatform = "aarch64-darwin";
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
    hostPlatform = hostPlatform;
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

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # nix.package = pkgs.nix;
 
  nix = {
    enable = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" "lukas" ];
    };
  };
  ids.uids.nixbld = 3000;
  nix-rosetta-builder.onDemand = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  homebrew = {
    enable = true;
    casks = [
      "alacritty"
      "docker"
      "firefox"
      "font-hack-nerd-font"
      "isabelle"
      "karabiner-elements"
      "keepassxc"
      "nextcloud"
      "signal"
      "telegram"
      "thunderbird"
      "vscodium"
    ];
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
      external_bar = "all:26:0";
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

  services.sketchybar = {
    enable = false;
    config =
      let
        sketchybar_src = pkgs.fetchFromGitHub {
            owner = "FelixKratz";
            repo = "SketchyBar";
            rev = "v2.19.4";
            hash = "sha256-6MqTyCqFv5suQgQ5a9t1mDA2njjFFgk67Kp7xO5OXoA=";
          };
        resetSpace = pkgs.writeScript "reset_space.bash" ''
          #!/usr/bin/env bash
          label=$(${pkgs.sketchybar}/bin/sketchybar --query $NAME | ${pkgs.jq}/bin/jq -r '.icon.value')
          read -d "\n" display focus visible <<< \
            $(${pkgs.yabai}/bin/yabai -m query --spaces --space $label | ${pkgs.jq}/bin/jq -r '.display,."has-focus",."is-visible"')
          space=(
            display=$display
            background.drawing=$(if $visible; then echo on; else echo off; fi)
            background.color=$(if $focus; then echo ${accentColor}; else echo ${bgColor}; fi)
            background.border_color=$(if $visible; then echo ${accentColor}; else echo ${bgColor}; fi)
          )
          ${pkgs.sketchybar}/bin/sketchybar --set $NAME "''${space[@]}"
          '';
      in
        ''
        default=(
          padding_left=4
          padding_right=4
          icon.font="Hack Nerd Font:Bold:17.0"
          label.font="Hack Nerd Font:Bold:14.0"
          icon.color=0xffffffff
          label.color=0xffffffff
          icon.padding_left=2
          icon.padding_right=2
          label.padding_left=2
          label.padding_right=2
        )
        sketchybar --default "''${default[@]}"
        sketchybar --bar color="${bgColor}"
        sketchybar --add event reset_spaces
        for label in $(yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | .label')
        do
          id=$(yabai -m query --spaces --space "$label" | ${pkgs.jq}/bin/jq -r '.id') 
          space=(
            icon="$label"
            icon.padding_left=7
            icon.padding_right=7
            label.drawing=off
            background.corner_radius=2
            background.border_width=2
            background.height=24
            script=${resetSpace}
            click_script="${pkgs.yabai}/bin/yabai -m space --focus $label"
          )
          sketchybar --add item "space.$id" left \
            --subscribe "space.$id" reset_spaces space_change display_change \
            --set "space.$id" "''${space[@]}"
        done
        sketchybar --trigger reset_spaces

        sketchybar --add item chevron left \
           --set chevron icon= label.drawing=off \
           --add item front_app left \
           --set front_app icon.drawing=off script="${sketchybar_src}/plugins/front_app.sh" \
           --subscribe front_app front_app_switched

        sketchybar --add item clock right \
           --set clock update_freq=10 icon=󰥔 script="${sketchybar_src}/plugins/clock.sh" \
           --add item volume right \
           --set volume script="${sketchybar_src}/plugins/volume.sh" \
           --subscribe volume volume_change \
           --add item battery right \
           --set battery update_freq=120 script="${sketchybar_src}/plugins/battery.sh" \
           --subscribe battery system_woke power_source_change

        sketchybar --update
        '';
        extraPackages = [
        ];
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
        ${super} + ${mod1} - k : yabai -m space --display north && ${pkgs.sketchybar}/bin/sketchybar --trigger reset_spaces  
        ${super} + ${mod1} - j : yabai -m space --display south && ${pkgs.sketchybar}/bin/sketchybar --trigger reset_spaces 
        ${super} + ${mod1} - h : yabai -m space --display west  && ${pkgs.sketchybar}/bin/sketchybar --trigger reset_spaces 
        ${super} + ${mod1} - l : yabai -m space --display east  && ${pkgs.sketchybar}/bin/sketchybar --trigger reset_spaces 
        ${super} - return : open -na /Applications/Alacritty.app
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

  users.users.lukas = {
    name = "lukas";
    home = "/Users/lukas";
  };

  system.primaryUser = "lukas";

  #home-manager.users.lukas = import ~/dotfiles/home/home.nix;
  #home-manager.users.lukas = { pkgs, ...}: {
  #  programs.zsh.enable = true;
  #  home.stateVersion = "23.11";
  #};
}
