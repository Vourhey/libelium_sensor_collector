{ stdenv
, mkRosPackage
, robonomics_comm
, python3Packages
}:

mkRosPackage rec {
  name = "${pname}-${version}";
  pname = "libelium_sensor_collector";
  version = "0.1.0";

  src = ./.;

  propagatedBuildInputs = [
    robonomics_comm
  ];

  meta = with stdenv.lib; {
    description = "";
    homepage = http://github.com/vourhey/libelium_sensor_collector;
    license = licenses.bsd3;
    maintainers = with maintainers; [ vourhey ];
  };
}
