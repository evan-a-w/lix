{lib, ...}: {
  # Evan's zsh additions on top of the shared modules/terminal.nix config.
  # mkOrder 1500 places this after terminal.nix's initContent (1000) and the
  # shared aliases (1100), so Evan's aliases/env win on conflicts.
  programs.zsh = {
    history = {
      size = 1000000000;
      save = 1000000000;
      path = "$HOME/.zsh_history";
    };
    initContent = lib.mkOrder 1500 (builtins.readFile ./zshrc.zsh);
  };

  # direnv: auto-load per-project flake dev shells on cd.
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
