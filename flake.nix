{
  description = "Mojo Jojo";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }: with pkgs; {
        default = mkShell {
          packages = [
            # Recommened package manager
            pixi
          ];

          shellHook = ''
            echo "Mojo Jojo ready!"
          '';
        };
      });
    };
}
