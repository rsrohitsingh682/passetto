{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";

    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };
  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, ... }: {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.process-compose-flake.flakeModule
      ];

      perSystem = { self', pkgs, ... }: {
        haskellProjects.default = { };
        process-compose."default" = {
          imports = [
            inputs.services-flake.processComposeModules.default
            self.processComposeModules.default
          ];
          services.passetto = {
            enable = true;
            pgweb.enable = true;
          };
        };
      };

      flake.processComposeModules.default = ./process-compose.nix;
    });
}
