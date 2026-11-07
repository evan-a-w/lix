# Evan's cross-platform home config (Linux + macOS). Platform-specific bits
# live in desktop.nix (Linux/GNOME) and mac.nix (aarch64-darwin).
{
  pkgs,
  lix,
  ...
}: {
  imports = [
    ../../modules/registry.nix
    ../../modules/terminal.nix
    ../../modules/common.nix
    ./shell.nix
    ./emacs.nix
  ];

  home.username = "evan";
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
    unzip
    atool
    httpie
    btop

    # Dev
    # oxcaml.oxcaml
    # oxcaml.ocamlformat
    # oxcaml.ocaml-lsp
    gh

    # opam
    autoconf
    gmp
    which

    python3
    git
    gnumake
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

    # Misc
    fastfetch
    cmatrix
  ];
}
