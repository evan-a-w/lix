{
  config,
  pkgs,
  lib,
  ...
}: let
  spacemacsDir = "${config.home.homeDirectory}/.emacs.d";
  # Editable checkout of the repo so Spacemacs can write its custom-settings
  # section back (and edits in emacs land in git).
  spacemacsFile = "${config.home.homeDirectory}/dev/lix/home/users/evan/spacemacs";
in {
  programs.emacs = {
    enable = true;
    # Native-compiled, pure GTK build (proper Wayland support for GNOME/niri).
    package = pkgs.emacs-pgtk;
    # Packages that need native bits are provided by nix rather than built by
    # package.el (which fails or is fiddly on NixOS). Spacemacs sees them as
    # already installed.
    extraPackages = epkgs: [
      epkgs.vterm
      epkgs.pdf-tools
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  home.file.".spacemacs".source = config.lib.file.mkOutOfStoreSymlink spacemacsFile;

  # Clone Spacemacs (develop branch, as upstream recommends) on first activation.
  # It stays a normal git checkout so `SPC f e U` / git pull updates work.
  home.activation.spacemacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "${spacemacsDir}/spacemacs.mk" ] && [ ! -e "${spacemacsDir}/core" ]; then
      if [ -e "${spacemacsDir}" ]; then
        run mv "${spacemacsDir}" "${spacemacsDir}.bak-$(date +%s)"
      fi
      run ${pkgs.git}/bin/git clone --depth 1 -b develop \
        https://github.com/syl20bnr/spacemacs "${spacemacsDir}"
    fi
  '';

  # rust-analyzer needs the std sources for completion / goto into std; nix's
  # rustc sysroot doesn't ship them. The spacemacs config imports this too.
  home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # font from dotspacemacs-default-font
    source-code-pro
    emacs-all-the-icons-fonts

    # ivy / projectile search
    ripgrep
    fd

    # lsp servers & formatters for the configured layers
    clang-tools # clangd + clang-format (c-c++)
    # OCaml (ocamllsp, ocamlformat) is deliberately not here: it must match
    # each project's compiler, so it comes from the project's nix shell via
    # direnv (`.envrc` with `use nix` / `use flake`) and envrc in emacs.
    rust-analyzer
    rustfmt
    clippy
    haskell-language-server
    zls
    pyright
    python3Packages.yapf
    typescript-language-server # javascript
    vscode-langservers-extracted # html/css/json
    yaml-language-server
    prettier
    sqlfluff
    shellcheck # syntax-checking
    multimarkdown # markdown preview
  ];
}
