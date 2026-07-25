{
  description = "Collection of programs packages for Nix by Colorman";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";

    # My packages
    # anchorr: Discord bot for sonarr/radarr requests
    anchorr = {
      url = "github:TheColorman/anchorr-nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # flux-schema: Flux CLI to generate kubernetes manifests
    flux-schema = {
      url = "github:TheColorman/flux-schema-nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pkgs-by-name.follows = "pkgs-by-name";
      };
    };
    # SeaDexArr: Seadex sync for Radarr/Sonarr
    seadexarr = {
      url = "github:TheColorman/seadexarr-nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # zfdash: vibe-coded ZFS dashboard
    zfdash.url = "github:TheColorman/zfdash-nix-flake";

  };

  outputs =
    inputs:
    let
      packages = name: inputs."${name}".packages;
      defaultNixosModule = name: inputs."${name}".nixosModules.default;
      defaultOverlay = name: inputs."${name}".overlays.default;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }: {
        systems = lib.systems.flakeExposed;

        perSystem = { system, ... }: {
          packages =
            let
              defaultPackage = name: (packages name).${system}.default;
            in
            lib.genAttrs [ "anchorr" "flux-schema" "seadexarr" "zfdash" ] defaultPackage;
        };

        flake = {
          nixosModules = lib.genAttrs [ "anchorr" "seadexarr" "zfdash" ] defaultNixosModule;
          overlays = lib.genAttrs [ "anchorr" "seadexarr" ] defaultOverlay;
        };
      }
    );
}
