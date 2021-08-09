{ pkgs ? import <nixpkgs> {} }:

let
  default = import ./default.nix {};

  buildInputs = builtins.attrValues {
    inherit (pkgs) gnumake which;

    inherit (default) purs pulp purp psc-package dhall-simple spago psa pscid spago2nix purescript-language-server purs-tidy purty zephyr;
  };

in
pkgs.mkShell {
  buildInputs = buildInputs;
}
