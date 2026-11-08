# Terminal-only home config for evan on NixOS-WSL.
{pkgs, ...}: {
  imports = [./common.nix];

  home.homeDirectory = "/home/evan";

  # Enable once ~/dev/lim2 is cloned inside WSL:
  # programs.lim = {
  #   enable = true;
  #   repo = "/home/evan/dev/lim2";
  # };

  home.packages = with pkgs; [
    gcc
  ];
}
