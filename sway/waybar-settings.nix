{ pkgs, ... }:

[
  {
    position = "top";
    modules-left = [ "sway/workspaces" "sway/mode" ];
    modules-center = [ "sway/window" ];
    modules-right = [ "backlight" "pulseaudio" "cpu" "memory" "battery" "network" "clock" "tray" ];
    modules = {
      "sway/window" = {
        format = "{}";
        max-length = 40;
      };
      backlight = {
        format = "{percent}% {icon}";
        format-icons = ["" ];
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +1%";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 1%-";
      };
      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-scroll-up = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
        on-scroll-down = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
        on-click-right = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
      };
      memory = {
  	    interval = 1;
  	    format = "{used:0.1f}G/{total:0.1f}G ";
      };
      battery = {
        interval = 30;
        states = {
            warning = 20;
            critical = 10; 
        };
        format = "{capacity}% {icon}";
        format-icons = ["" "" "" "" ""];
        max-length = 25;
      };
      network = {
  	    format = "{ifname}";
  	    format-wifi = "{essid} ({signalStrength}%) ";
  	    format-ethernet = "{ifname} ";
  	    format-disconnected = "";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  	    max-length = 50;
      };
      clock = {
        interval = 1;
        format = "{:%F %H:%M:%S}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };
    };
  }
]
