{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) home-manager;
in {
  users.users.evan = {
    isNormalUser = true;
    description = "Evan Williams";
    extraGroups = [
      "wheel" # Allows use of sudo
      "networkmanager"
      "input"
      "plugdev"
      "audio"
      "video"
      "docker"
      "libvirtd"
      "kvm"
      "dialout"
      "adbusers"
    ];
    shell = pkgs.zsh;
    packages = [home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager];
  };

  services.netbird.enable = true;
}
