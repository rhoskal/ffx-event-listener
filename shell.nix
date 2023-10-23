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
    pkgs.nodejs_20
    pkgs.nodePackages.pnpm
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted
    pkgs.nodePackages.yaml-language-server
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
