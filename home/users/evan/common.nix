{
  pkgs,
  lib,
  lix,
  ...
}: {
  imports = [
    ../../modules/registry.nix
    ../../modules/terminal.nix
    ../../modules/wayland-fixes.nix
    ../../modules/common.nix
    ./shell.nix
    ./emacs.nix
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

  home.username = "evan";
  home.homeDirectory = "/home/evan";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    NH_FLAKE = "path:" + lix.dir; # for nix helper to not require a path
  };

  home.packages = with pkgs; [
    # fuck ai
    codex
    claude-code
    prigh

    # Utils
    nh # Nix helper
    pkgs.lix.dev
    kdePackages.filelight # disk usage gui
    unzip
    atool
    httpie
    evtest
    scrcpy
    btop
    openvpn
    nautilus
    # bottles
    piper
    acpi

    # Dev
    # oxcaml.oxcaml
    # oxcaml.ocamlformat
    # oxcaml.ocaml-lsp
    docker
    gh

    # opam
    autoconf
    gmp
    which

    autoconf
    python3
    git
    gnumake
    gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs
    pnpm
    bun

    zig

    # Rust
    cargo
    rustc

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
    fastfetch
    cmatrix
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
