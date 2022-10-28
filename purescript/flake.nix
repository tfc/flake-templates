{
  description = "purescript hello world";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs";
    pre-commit-hooks = {
      url = "github:tfc/pre-commit-hooks.nix?ref=purs-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    purs-nix-input.url = "github:ursi/purs-nix";
  };

  outputs =
    { self
    , flake-parts
    , nixpkgs
    , pre-commit-hooks
    , purs-nix-input
    }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          purs-nix = purs-nix-input { inherit system; };

          filteredSrc = pkgs.lib.sourceByRegex ./. [
            "^src.*"
            "^package.json$"
            "^package-lock.json$"
          ];

          ps = purs-nix.purs {
            dependencies = with purs-nix.ps-pkgs; [
              console
              effect
              prelude
            ];

            dir = filteredSrc;
          };

          ps-command = ps.command {
            bundle.esbuild = {
              outfile = "bundle.js";
              minify = true;
            };
          };

          nodeDependencies =
            let
              env = { nativeBuildInputs = [ pkgs.node2nix ]; };
              drv = pkgs.runCommand "node-dependencies" env ''
                mkdir $out
                cd $out
                node2nix --input ${filteredSrc}/package.json \
                         --lock ${filteredSrc}/package-lock.json \
                         --nodejs-18 \
                         --development
              '';
            in
            (import drv { inherit pkgs; inherit (pkgs) nodejs; }).nodeDependencies;
        in
        {
          devShells.default = pkgs.mkShell {
            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
            '';
            nativeBuildInputs = with pkgs; [
              electron
              node2nix
              nodejs
              ps-command
            ];
          };

          packages = {
            default = config.packages.bundle;
            bundle = pkgs.stdenv.mkDerivation {
              name = "hello-world-bundle";
              src = filteredSrc;
              nativeBuildInputs = with pkgs; [
                nodejs
                ps-command
              ];
              buildPhase = ''
                ln -s ${nodeDependencies}/lib/node_modules ./node_modules
                export PATH="${nodeDependencies}/bin:$PATH"

                npm run build
                eval "$postBuild"
              '';
              installPhase = ''
                cp -r dist $out
              '';
            };
          };

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                purs-tidy.enable = true;
                statix.enable = true;
              };
            };
          };
        };
    };
}
