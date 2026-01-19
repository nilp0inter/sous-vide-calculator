{
  description = "Sous Vide Calculator - Elm + Tailwind development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            elmPackages.elm
            elmPackages.elm-format
            elmPackages.elm-review
            elmPackages.elm-test
            elmPackages.elm-language-server
            nodejs_22
            nodePackages.npm
          ];

          shellHook = ''
            echo "Welcome to the Sous Vide Calculator dev environment!"
            echo "Elm $(elm --version)"
            echo "Node $(node --version)"
          '';
        };
      }
    );
}
