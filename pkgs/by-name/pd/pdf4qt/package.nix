{
  lib,
  stdenv,
  fetchFromGitHub,
  lcms,
  cmake,
  pkg-config,
  qt6,
  wrapGAppsHook3,
  openjpeg,
  tbb_2021_11,
  blend2d,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdf4qt";
  version = "1.5.0.0";

  src = fetchFromGitHub {
    owner = "JakubMelka";
    repo = "PDF4QT";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ELdmnOEKFGCtuf240R/0M6r8aPwRQiXurAxrqcCZvOI=";
  };

  patches = [
    # lcms2 cmake module only appears when built with vcpkg.
    # We directly search for the corresponding libraries and
    # header files instead.
    ./find_lcms2_path.patch
  ];

  # make calls to QString::arg compatible with Qt 6.9
  # see https://doc-snapshots.qt.io/qt6-6.9/whatsnew69.html#new-features-in-qt-6-9
  postPatch = ''
    substituteInPlace Pdf4QtLibCore/sources/pdf{documentsanitizer,optimizer}.cpp \
      --replace-fail \
        '.arg(counter)' \
        '.arg<PDFInteger>(counter)'
    substituteInPlace Pdf4QtLibCore/sources/pdfoptimizer.cpp \
      --replace-fail \
        '.arg(bytesSaved)' \
        '.arg<PDFInteger>(bytesSaved)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
    # GLib-GIO-ERROR: No GSettings schemas are installed on the system
    wrapGAppsHook3
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtsvg
    qt6.qtspeech
    lcms
    openjpeg
    tbb_2021_11
    blend2d
  ];

  cmakeFlags = [
    (lib.cmakeBool "PDF4QT_INSTALL_TO_USR" false)
  ];

  dontWrapGApps = true;

  preFixup = ''
    qtWrapperArgs+=(''${gappsWrapperArgs[@]})
  '';

  meta = {
    description = "Open source PDF editor";
    longDescription = ''
      This software is consisting of PDF rendering library,
      and several applications, such as advanced document
      viewer, command line tool, and document page
      manipulator application. Software is implementing PDF
      functionality based on PDF Reference 2.0.
    '';
    homepage = "https://jakubmelka.github.io";
    license = lib.licenses.lgpl3Only;
    mainProgram = "Pdf4QtViewerLite";
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
  };
})
