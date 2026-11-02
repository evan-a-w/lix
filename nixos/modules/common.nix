{
  pkgs,
  lix,
  ...
}: {
  environment.sessionVariables = {
    LIX_DIR = toString lix.dir;
  };

  # Keep SSH socket so I can use SSH for nixos switch as su
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable audio
  services.pulseaudio.enable = false;
  services.dbus.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  nix.settings.trusted-users = [
    "root"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    kitty
  ];

  # connect to my nfs through netbird ip
  fileSystems."/mnt/truenas/server-nfs" = {
    device = "100.87.55.150:/mnt/main/server-nfs";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "_netdev"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # connect to my smb share through netbird ip
  fileSystems."/mnt/share" = {
    device = "//100.87.55.150/share";
    fsType = "cifs";
    options = [
      "uid=1000"
      "gid=100"
      "vers=3.1.1"
      "_netdev"
      # mount on first access, so boot won't hang if NetBird isn't up yet
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.after=netbird.service"
    ];
  };

  system.stateVersion = "24.11";
}
