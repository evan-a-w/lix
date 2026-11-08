# Terminal-only home config for evan on Ubuntu under WSL2 (home-manager on a
# non-NixOS distro, with a single-user Nix install).
{pkgs, ...}: {
  imports = [./common.nix];

  home.homeDirectory = "/home/evan";

  # Non-NixOS fixes: XDG_DATA_DIRS, terminfo, locale archive, etc.
  targets.genericLinux.enable = true;

  # home-manager owns ~/.zshenv, so it has to load Nix itself (this replaces
  # the line the Nix installer added to the old ~/.zshenv).
  programs.zsh.envExtra = ''
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
  '';

  home.packages = with pkgs; [
    gcc
  ];
}
