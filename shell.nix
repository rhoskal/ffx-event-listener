let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };

  basePackages = [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-language-server
    pkgs.elmPackages.elm-review
    pkgs.elmPackages.elm-test
    pkgs.nixfmt
    pkgs.nodejs-18_x
    pkgs.yarn
  ];

  inputs = basePackages;

  hooks = ''
    mkdir -p .nix-elm
    export ELM_HOME=$PWD/.nix-elm
  '';
in pkgs.mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}
