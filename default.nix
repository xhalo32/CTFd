{
  config,
  lib,
  dream2nix,
  ...
}:
let
  inherit (config.deps)
    python
    system
    pkgs
    stdenv
    ;
in
{
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps =
    { nixpkgs, pybluemonday, ... }:
    {
      python = nixpkgs.python311;
      system = nixpkgs.system;
      pkgs = nixpkgs;
    };

  name = "ctfd";

  version = "3.7.3";

  mkDerivation = {
    src = lib.cleanSourceWith {
      src = lib.cleanSource ./.;
      filter =
        name: type:
        !(builtins.any (x: x) [
          (lib.hasSuffix ".nix" name)
          (lib.hasPrefix "." (builtins.baseNameOf name))
          (lib.hasSuffix "flake.lock" name)
        ]);
    };
  };

  buildPythonPackage = {
    pyproject = true;
    catchConflicts = false;
    pythonImportsCheck = [
      "CTFd"
    ];

    dependencies = (
      with python.pkgs;
      [
        pymysql
        cmarkgfm
        gevent
        alembic
        six
        (dataset.overridePythonAttrs (oa: {
          propagatedBuildInputs = [
            alembic
            banal
            # sqlalchemy # comes from pip
          ];
          meta.broken = false;
        }))
        flask-migrate

        gunicorn

        python-geoacumen-city
        pybluemonday
      ]
    );
  };

  paths.lockFile = "lock.${stdenv.system}.json";

  pip = {
    flattenDependencies = true;

    requirementsList = [
      # "alembic==1.4.3"
      "aniso8601==8.0.0"
      "attrs==20.3.0"
      "babel==2.12.1"
      "banal==1.0.6"
      "boto3==1.34.39"
      "botocore==1.34.39"
      "cachelib==0.9.0"
      "certifi==2022.12.7"
      "charset-normalizer==2.0.12"
      "click==7.1.2"
      # "dataset==1.6.2"
      "flask==2.0.3"
      "flask-babel==2.0.0"
      "flask-caching==2.0.2"
      "flask-marshmallow==0.10.1"
      # "flask-migrate==2.5.3"
      "flask-restx==1.1.0"
      "flask-script==2.0.6"
      "flask-sqlalchemy==2.5.1"
      "freezegun==1.2.2"
      "greenlet==3.0.3"
      "idna==2.10"
      "itsdangerous==2.1.2"
      "jinja2==3.1.2"
      "jmespath==0.10.0"
      "jsonschema==3.2.0"
      "mako==1.1.3" # TODO alembic has this dependency
      "markupsafe==2.1.3"
      "marshmallow==2.20.2"
      "marshmallow-sqlalchemy==0.17.0"
      "passlib==1.7.4"
      "pillow==10.1.0"
      "pydantic==1.6.2"
      "pyrsistent==0.17.3"
      "python-dateutil==2.8.1"
      "python-dotenv==0.13.0"
      "python-editor==1.0.4"
      "pytz==2020.4"
      "redis==4.5.5"
      "requests==2.28.1"
      "s3transfer==0.10.0"
      "sqlalchemy==1.4.48"
      "sqlalchemy-utils==0.41.1"
      "tenacity==6.2.0"
      "urllib3==1.25.11"
      "werkzeug==2.0.3"
      "wtforms==2.3.1"
      # "zope-event==4.5.0"
    ];

    pipFlags = [
      "--no-binary"
      ":all:"
    ];

    overrideAll = {
      mkDerivation.nativeBuildInputs = with python.pkgs; [ setuptools ];
      buildPythonPackage.dependencies = with python.pkgs; [ setuptools ];
      buildPythonPackage.catchConflicts = false;
    };
    overrides = {
      jsonschema = {
        buildPythonPackage.build-system = with python.pkgs; [
          setuptools-scm
        ];
      };
      python-dateutil = {
        mkDerivation.nativeBuildInputs = with python.pkgs; [ setuptools-scm ];
      };
      tenacity = {
        mkDerivation.nativeBuildInputs = with python.pkgs; [ setuptools-scm ];
      };
    };
  };

  # meta = {
  #   description = "Capture The Flag framework";
  #   homepage = "https://github.com/CTFd/CTFd";
  #   license = lib.licenses.asl20;
  #   # maintainers = with lib.maintainers; [ niklashh ];
  #   mainProgram = "ctfd";
  # };
}
