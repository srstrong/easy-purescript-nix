{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
, nodejs ? pkgs.nodejs
, purs
}:

let
  # one should be able to regenarate using process substitution
  # ```fish
  # spago2nix generate 4 -- \
  #   --config (echo "https://raw.githubusercontent.com/natefaubion/purescript-tidy/v${version}/bin/spago.dhall" | psub)
  # ```
  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  pname = "purs-tidy";
  version = "0.3.1";

  src = pkgs.fetchgit {
    url = "https://github.com/natefaubion/purescript-tidy.git";
    rev = "v${version}";
    sha256 = "sha256-1woVnlv+7e3REHFdEHyRNxb5RsoSUHiI+JnnBl24BqQ=";
  };

  buildInputs = [
    spagoPkgs.installSpagoStyle
    spagoPkgs.buildSpagoStyle
    spagoPkgs.buildFromNixStore
    purs
  ];
  nativeBuildInputs = [ nodejs ];

  # this allows us to drop the package.json file all together
  patchPhase = ''
    substituteInPlace bin/Bin/Version.js \
      --replace 'require("../../package.json").version' '"${version}"';
  '';

  unpackPhase = ''
    cp $src/{packages,spago}.dhall .
    cp -r $src/bin $src/src .
    install-spago-style
  '';

  buildPhase = ''
    ls -a
    build-spago-style "./src/**/*.purs" "./bin/**/*.purs"
  '';

  installPhase = ''
    mkdir -p $out/{bin,output}
    cp -r output/ $out
    cp $src/bin/index.js $out/bin/purs-tidy
    chmod u+x $out/bin/purs-tidy
  '';
}
