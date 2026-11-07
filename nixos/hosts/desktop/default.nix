{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui.nix
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
    ../../modules/prigh-worker.nix
  ];

  # For nfs
  services.rpcbind.enable = true;
  services.gvfs.enable = true;
  environment.systemPackages = with pkgs; [
    nfs-utils
    gvfs
  ];

  # Extra SSDs (nofail: boot carries on if one is missing or fails to mount)
  # TEAM 2TB, ext4
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/aabeb877-3307-42ad-bfca-4f27bfe573e1";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=10s"];
  };

  # TEAM 2TB, Windows (NTFS)
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/8694672C94671E45";
    fsType = "ntfs3";
    options = ["nofail" "x-systemd.device-timeout=10s" "uid=1000" "gid=100" "umask=022"];
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # For vm support via virt-manager and libvirtd
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  # -----

  system.stateVersion = "24.11";
  networking.hostName = "desktop";
  hardware.logitech.wireless.enable = true;

  nix.settings.trusted-users = ["@wheel"]; # Allow all wheel group users extra nix perms

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  networking.firewall.allowedTCPPorts = [1701 5432 57621];
  networking.firewall.allowedUDPPorts = [5353];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  virtualisation.docker = {
    enable = true;

    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      UseDns = true;
      PasswordAuthentication = true;
    };
  };
}
