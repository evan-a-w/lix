{
  inputs,
  self,
  config,
  ...
}: let
  mkHost = system: modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      # this injects lix as an arg in all modules
      specialArgs = {
        inherit inputs self;
        lix = config.lix;
      };

      # adds lix sharedModules to config
      modules =
        modules
        ++ config.lix.os.sharedModules
        ++ [{nixpkgs.overlays = [self.overlays.default];}];
    };

  # { "server-<folder>" = module; } from ./hosts/servers
  servers = builtins.mapAttrs (_: module: mkHost "x86_64-linux" [module]) (import ./hosts/servers);
in {
  flake.nixosConfigurations =
    {
      desktop = mkHost "x86_64-linux" [./hosts/desktop];
      laptop = mkHost "x86_64-linux" [./hosts/laptop];
      wsl = mkHost "x86_64-linux" [./hosts/wsl];
    }
    // servers;
}
