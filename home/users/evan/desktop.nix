# Linux (GNOME) desktop for evan.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./common.nix
    ../../modules/wayland-fixes.nix
  ];

  # GNOME desktop (no niri gui module / gammastep)
  dconf.settings = {
    "org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
    # Replaces gammastep: constant 4500K warmth
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 0.0;
      night-light-schedule-to = 0.0;
      night-light-temperature = lib.hm.gvariant.mkUint32 4500;
    };
  };

  programs.lim = {
    enable = true;
    repo = "/home/evan/dev/lim2";
  };

  home.homeDirectory = "/home/evan";

  home.packages = with pkgs; [
    # Utils
    kdePackages.filelight # disk usage gui
    evtest
    scrcpy
    openvpn
    nautilus
    # bottles
    piper
    acpi

    # Dev
    gcc
    docker

    # Media / Audio
    easyeffects
    # audacity
    spotify
    vlc
    google-chrome
    zen-browser

    # Documents
    geeqie
    zathura
    xournalpp
    onlyoffice-desktopeditors

    # Comms
    discord

    # Game
    prismlauncher

    # Misc
    artisan
  ];

  # default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["google-chrome.desktop"];
      "x-scheme-handler/http" = ["google-chrome.desktop"];
      "x-scheme-handler/https" = ["google-chrome.desktop"];
      "application/pdf" = ["google-chrome.desktop"];
    };
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
}
