{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  check,
  flex,
  pkg-config,
  which,
  elfutils,
  libffi,
  llvm,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "nvc";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "nickg";
    repo = "nvc";
    rev = "r${version}";
    hash = "sha256-RI86VdWuPTcjkQstwDBN/rDLv/Imy9kYH/nIJSGuIcI=";
  };

  nativeBuildInputs = [
    autoreconfHook
    check
    flex
    pkg-config
    which
  ];

  buildInputs =
    [
      libffi
      llvm
      zlib
      zstd
    ]
    ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform elfutils) [
      elfutils
    ];

  preConfigure = ''
    mkdir build
    cd build
  '';

  configureScript = "../configure";

  configureFlags = [
    "--enable-vhpi"
    "--disable-lto"
  ];

  doCheck = true;

  meta = with lib; {
    description = "VHDL compiler and simulator";
    mainProgram = "nvc";
    homepage = "https://www.nickg.me.uk/nvc/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}
