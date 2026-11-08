# NixOS running under WSL2 on Windows (via nix-community/NixOS-WSL).
# Deliberately does not import ../../modules/common.nix: bluetooth, audio,
# NetworkManager and the NFS/SMB mounts don't make sense inside WSL.
{
  inputs,
  pkgs,
  lib,
  lix,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/users/evan.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "evan";
    startMenuLaunchers = true;
  };

  networking.hostName = "wsl";

  # NetBird is enabled in users/evan.nix; it fights with WSL's networking
  services.netbird.enable = lib.mkForce false;

  environment.sessionVariables.LIX_DIR = toString lix.dir;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "@wheel"];
  };

  # Keep SSH socket so I can use SSH for nixos switch as su
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.zsh.enable = true;
  # Lets unpatched dynamic binaries (e.g. VS Code remote server) run
  programs.nix-ld.enable = true;

  virtualisation.docker = {
    enable = true;
    daemon.settings.dns = ["1.1.1.1" "8.8.8.8"];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  system.stateVersion = "25.05";
}
