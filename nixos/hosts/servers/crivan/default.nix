# laptop-specific config (imported by ../common.nix)
{
  config,
  lib,
  ...
}: {
  imports = [../../../modules/prigh-worker.nix ../../../modules/users/evan.nix ../../../modules/gui.nix
../../../modules/nvidia.nix
  ];

  # Bootloader: GRUB in UEFI mode, installed to the EFI partition at /boot,
  # so no disk device (/dev/sda etc.) is needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # GNOME instead of niri on this machine.
  services.desktopManager.gnome.enable = true;
  services.displayManager.defaultSession = lib.mkForce "gnome";
  programs.niri.enable = lib.mkForce false;

  # Daemon for Piper (mouse DPI/buttons config)
  services.ratbagd.enable = true;

  # GTX 980 Ti (Maxwell): unsupported by the open kernel module (needs GSP,
  # Turing+) and by NVIDIA drivers >= 590. Use the proprietary 580 branch.
  hardware.nvidia = {
    open = lib.mkForce false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    modesetting.enable = true;
  };

  # `gamemoderun %command%` in Steam launch options: performance CPU governor
  # and higher priority while a game runs.
  programs.gamemode.enable = true;
  users.users.evan.extraGroups = ["gamemode"];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
