{
  description = "A basic flake";

  inputs.systems.url = "github:nix-systems/default";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.nixpkgs.follows = "dream2nix/nixpkgs";

  inputs.pybluemonday.url = "github:xhalo32/pybluemonday";
  inputs.pybluemonday.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      systems,
      nixpkgs,
      dream2nix,
      ...
    }@inputs:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
      overlay = (
        final: prev: {
          python311 = prev.python311.override {
            packageOverrides = finalPython: prevPython: {
              python-geoacumen-city = prev.python311.pkgs.callPackage ./python-geoacumen-city.nix { };

              pybluemonday = inputs.pybluemonday.packages.${prev.system}.pybluemonday;
            };
          };
        }
      );
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        rec {
          ctfd = dream2nix.lib.evalModules {
            packageSets.nixpkgs = pkgs;
            modules = [
              ./default.nix

              {
                paths.projectRoot = ./.;
                paths.projectRootFile = "flake.nix";
                paths.package = ./.;
              }
            ];
          };

          default = ctfd;
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
          python = pkgs.python311;
        in
        {
          default = pkgs.mkShell {
            name = "devshell";
            buildInputs =
              (with python.pkgs; [
                pkgs.sqlite
                gunicorn
                # (python.withPackages (
                #   ps: with ps; [
                #     pymysql
                #     cmarkgfm
                #     gevent
                #     six
                #     python-geoacumen-city
                #     pybluemonday
                #   ]
                # ))
                (self.packages.${system}.ctfd.pyEnv.override (args: {
                  ignoreCollisions = true;
                }))
              ])
              ++ self.packages.${system}.ctfd.config.buildPythonPackage.dependencies;
          };
        }
      );
    };
}
