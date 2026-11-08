{
  description = "Lix--A NixOS and Home Manager Configuration";

  nixConfig = {
    extra-substituters = ["https://vicinae.cachix.org" "https://prigh.cachix.org"];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "prigh.cachix.org-1:1kHKoGOetNmpzJg8lJ1nvQzwzTL0XiOs5GInELMgSoI="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    old-nixpkgs.url = "github:NixOS/nixpkgs/25.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vicinae.url = "github:vicinaehq/vicinae";

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lim = {
      url = "github:lloyd-g-w/lim2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    latus = {
      url = "github:lloyd-g-w/latus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prigh = {
      url = "github:evan-a-w/prigh";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      imports =
        [
          inputs.home-manager.flakeModules.home-manager
          ./options # This exposes the avaliable lix options
          ./nixos
          ./home
          ./overlays
          ./pkgs
          ./shells
          ./templates
        ]
        ++ (
          if builtins.pathExists ./config.nix
          then [./config.nix]
          else []
        );

      lix.home.sharedModules = [
        inputs.vicinae.homeManagerModules.default
        inputs.lim.homeManagerModules.default
        inputs.mangowm.hmModules.mango
      ];

      lix.os.sharedModules = [
        inputs.mangowm.nixosModules.mango
      ];
    };
}
