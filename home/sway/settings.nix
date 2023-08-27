{ pkgs, lib, config, ... } :

let
  bgColor = "#${config.scheme.base00}";
  inactiveBgColor = "#${config.scheme.base01}";
  textColor = "#${config.scheme.base05}";
  inactiveTextColor = "#${config.scheme.base06}";
  urgentBgColor = "#${config.scheme.base04}";
  blueAccent = "#${config.scheme.base0D}";
  indicatorColor = "#${config.scheme.base00}";

  stripHash = s: lib.strings.removePrefix "#" s;

  workspaces = [
    "10: home"
    "1" "2" "3" "4"
    "5: music" "6: msg" "7: mail" "8: www" "9: term"
  ];
in
  rec {
    fonts = {
      names = [ "Inconsolata" ];
      style = "Regular";
      size = 12.0;
    };
  
    terminal = "${pkgs.alacritty}/bin/alacritty";

    menu = "${pkgs.rofi-wayland}/bin/rofi -config ${config.scheme {
      template = ''
        * {
          background: ${bgColor};
          background-alt: ${inactiveBgColor};
          foreground: ${textColor};
          selected: ${blueAccent};
          active:  #${config.scheme.base0A};
          urgent: ${urgentBgColor};
        }
        configuration {
          modi: "drun,emoji,run,filebrowser";
            show-icons:           false;
            display-drun:         " Apps";
            display-emoji:        "😎 Emoji";
            display-run:          " Run";
            display-filebrowser:  " Files";
            /* display-window:    " Windows"; */
        	  drun-display-format:  "{name}";
        }
        '' +
        builtins.readFile ./rofi.mustache;
    }}";
  
    modifier = "Mod4";
    left = "h";
    down = "j";
    up = "k";
    right = "l";

    startup = [ 
      { command = "${terminal} --title scratchterm"; }
      { command = "${pkgs.keepassxc}/bin/keepassxc"; }
    ]; 
  
    window.commands = [
      { command = "move scratchpad"; criteria = { title = "scratchterm"; }; }
      { command = "move scratchpad"; criteria = { title = "KeePassXC"; app_id = "KeePassXC"; }; }
      { command = "move to workspace ${pkgs.lib.lists.elemAt workspaces 5}"; criteria = { class = "Spotify"; }; }
    ];

    floating.criteria = [
      { app_id = "KeePassXC"; }
      { title = "scratchterm"; }
    ];

    assigns = with pkgs.lib.lists; {
      "${elemAt workspaces 7}" = [{ app_id = "thunderbird"; }];
      "${elemAt workspaces 6}" = [{ class = "discord"; } { app_id = "org.telegram.desktop"; } { class = "Signal"; }];
      "${elemAt workspaces 8}" = [{ app_id = "firefox"; }];
      "${elemAt workspaces 5}" = [{ class = "Spotify"; }];
    };
  
    colors =
      let
        withDefault = cs: cs // { childBorder = cs.background; indicator = indicatorColor; };
      in {
        focused = withDefault { background = blueAccent; border = bgColor; text = textColor; };
        unfocused = withDefault { background = inactiveBgColor; border = inactiveBgColor; text = inactiveTextColor; };
        focusedInactive = withDefault { background = inactiveBgColor; border = inactiveBgColor; text = inactiveTextColor; };
        urgent = withDefault { background = urgentBgColor; border = urgentBgColor; text = textColor; };
      };

    bars = [
      {
        command = "${pkgs.waybar}/bin/waybar";
        fonts = {
          names = [ "Inconsolata" "FontAwesome" ];
          style = "Regular";
          size = 10.0;
        };
        position = "top";
        trayOutput = "primary";
      }
    ];
  
    input = {
      "type:keyboard" = { xkb_variant = "us"; xkb_options = "compose:caps"; };
      "type:touchpad" = {
        pointer_accel = "0.3";
        tap = "enabled";
        tap_button_map = "lrm";
        dwt = "enabled";
      };
    };
  
    keybindings = with pkgs.lib.lists;
      let
        concatAttrs = xs: foldr (a: b: a // b) {} xs;
        concatAttrsMap = f: xs: concatAttrs (map f xs);
        genMovementBindings = 
          concatAttrsMap (dirs: {
            "${modifier}+${dirs.snd}" = "focus ${dirs.fst}";
            "${modifier}+Shift+${dirs.snd}" = "move ${dirs.fst} 60px";
            "${modifier}+Control+${dirs.snd}" = "move workspace to output ${dirs.fst}";
          }) (zipLists ["left" "down" "up" "right"] [left down up right]);
        genWorkspaceBindings = wss: 
          concatAttrsMap (ews: {
            "${modifier}+${ews.fst}" = "workspace ${ews.snd}"; 
            "${modifier}+Shift+${ews.fst}" = "move container to workspace ${ews.snd}";

          }) (zipLists (map toString (range 0 10)) wss);
      in {
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+e" = "exec \"swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes, exit sway.' 'swaymsg exit'\"";
        "${modifier}+Shift+x" = "exec \"${pkgs.swaylock}/bin/swaylock --color ${stripHash bgColor}\"";
  
        "${modifier}+Shift+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+r" = "mode resize";
        "${modifier}+v" = "split toggle";
        "${modifier}+w" = "layout toggle tabbed split";
        "${modifier}+e" = "layout toggle split";
  
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+t" = "[title=\"scratchterm\"] scratchpad show";
        "${modifier}+p" = "[app_id=\"KeePassXC\"] scratchpad show";
  
        "${modifier}+d" = "exec \"${menu} -show drun -show-icons\"";

        "XF86AudioRaiseVolume" = "exec --no-startup-id \"${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +3%\"";
        "XF86AudioLowerVolume" = "exec --no-startup-id \"${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -3%\"";
        "XF86AudioMute" = "exec --no-startup-id \"${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle\"";
        "XF86MonBrightnessUp" = "exec --no-startup-id \"${pkgs.brightnessctl}/bin/brightnessctl set +10%\"";
        "XF86MonBrightnessDown" = "exec --no-startup-id \"${pkgs.brightnessctl}/bin/brightnessctl set 10%-\"";
        "XF86AudioPlay" = "exec --no-startup-id \"${pkgs.playerctl}/bin/playerctl play-pause\"";
        "XF86AudioNext" = "exec --no-startup-id \"${pkgs.playerctl}/bin/playerctl next\"";
        "XF86AudioPrev" = "exec --no-startup-id \"${pkgs.playerctl}/bin/playerctl previous\"";

        "${modifier}+a" = "focus parent";
        "${modifier}+s" = "focus child";

        "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\"";
        "Shift+Print" = "exec ${pkgs.grim}/bin/grim -t png -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
      } // genMovementBindings // genWorkspaceBindings workspaces;
  }
