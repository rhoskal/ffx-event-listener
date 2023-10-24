let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };

  basePackages = [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-language-server
    pkgs.nixfmt
    pkgs.nodejs_20
    pkgs.nodePackages.pnpm
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
