self: super: let
  python = super.python3;
  pname = "colcon-mixin";
  version = "0.2.1";
in {
  python3Packages =
    super.python3Packages
    // {
      colcon-mixin = python.pkgs.buildPythonPackage {
        inherit pname version;

        src = python.pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-tlN59WhTQ8+9hM565YOWZSO3tk14ahCN1YQ8kwkpl64=";
        };

        doCheck = false;
        propagatedBuildInputs = [python.pkgs.setuptools];
      };
    };
}
