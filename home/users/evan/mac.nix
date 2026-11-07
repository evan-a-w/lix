# macOS (aarch64-darwin, standalone home-manager) for evan.
#   nh home switch            (with NH_FLAKE set, after the first switch)
#   nix run home-manager -- switch -b bak --flake path:$HOME/dev/lix#evan@mac
{lib, ...}: {
  imports = [./common.nix];

  home.homeDirectory = "/Users/evan";

  # Copy (not symlink) .app bundles into ~/Applications/Home Manager Apps so
  # Spotlight / Launchpad / `open -a` find them (eg. Emacs.app).
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;

  programs.zsh = {
    # home-manager owns ~/.zprofile. Login shells run it before /etc/zshrc puts
    # nix on PATH, so nix binaries still win over brew ones.
    profileExtra = ''
      [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    # home-manager owns ~/.zshenv; this is what the old ~/.zshenv + ~/.zprofile
    # did (zshenv so non-interactive shells, eg. emacs', get them too).
    envExtra = ''
      # JVM installed by coursier
      export JAVA_HOME="$HOME/Library/Caches/Coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%252B7/OpenJDK11U-jdk_x64_mac_hotspot_11.0.22_7.tar.gz/jdk-11.0.22+7/Contents/Home"
      export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"
      export PATH="$HOME/.elan/bin:$PATH"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

      # Non-interactive zsh (eg. GUI emacs running `. ~/.zshrc; echo $PATH`)
      # never reads /etc/zshrc, which is where macOS gets nix on PATH.
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
    initContent = lib.mkOrder 1600 (builtins.readFile ./mac.zsh);
  };
}
