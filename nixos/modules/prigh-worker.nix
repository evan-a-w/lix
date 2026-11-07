# prigh-worker.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.prigh-worker;
in {
  options.prigh-worker.user = lib.mkOption {
    type = lib.types.str;
    default = "lloyd";
    description = "The user the prigh tool host runs as; it starts in that user's home.";
  };

  config.systemd.services.prigh-worker = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = [pkgs.prigh "/run/wrappers" "/run/current-system/sw" "/etc/profiles/per-user/laptopserver"];
    serviceConfig = {
      User = cfg.user;
      EnvironmentFile = "/etc/prigh-worker.env"; # PRIGH_TOKEN=...
      Restart = "always";
      RestartSec = 10;
    };
    script = "exec prigh tool-host -connect $PRIGH_HOST:7790 -user $PRIGH_USER -token $PRIGH_TOKEN -cwd ${config.users.users.${cfg.user}.home}";
  };
}
