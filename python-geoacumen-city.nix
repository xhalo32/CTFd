{
  python,
  buildPythonPackage,
  fetchFromGitHub,

  # Python packages
  setuptools,
  maxminddb,
  ...
}:
let
  # NOTE 09 is normalized to 9
  # python3.12-python-geoacumen-city> /nix/store/l7idy2qiiv0v0b6khfjvz3l5k6mnm47l-python3.12-setuptools-72.1.0/lib/python3.12/site-packages/setuptools/dist.py:289: InformationOnly: Normalizing '2024.09.15' to '2024.9.15'
  year = "2024";
  month = "09";
  name = "dbip-city-lite-${year}-${month}.mmdb.gz";
  data = builtins.fetchurl {
    url = "https://download.db-ip.com/free/${name}";
    sha256 = "0g8iq8v0hgsj1y8vkzh6mjjci466hav89wjsd3vcirf8hps53p6d";
  };
in
buildPythonPackage {
  pname = "python-geoacumen-city";
  version = "${year}.${month}.15";
  pyproject = true;

  postPatch = ''
    ln -s ${data} ${name}
    substituteInPlace setup.py \
      --replace-fail 'year_month = datetime.datetime.now().strftime("%Y-%m")' 'year_month = "${year}-${month}"' \
      --replace-fail 'subprocess.call(["curl' '# subprocess.call(["curl'
  '';

  src = fetchFromGitHub {
    owner = "geoacumen";
    repo = "python-geoacumen-city";
    rev = "3c027806c0411c8cb988fb72742f7ab7ee5c9927";
    hash = "sha256-YNuyFgu1YsPSsVoPLdGaW1zf9uajhTEq6a9o4OnPh8w=";
  };

  build-system = [ setuptools ];

  dependencies = [ maxminddb ];
}
