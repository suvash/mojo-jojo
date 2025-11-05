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
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        inherit system;
      });
    in
    {
      devShells = forAllSystems ({ pkgs, system }:
        let
          isLinux = system == "x86_64-linux";
          cudaPackages = [
            pkgs.cudatoolkit
            pkgs.cudaPackages.cudnn
            pkgs.cudaPackages.cuda_cudart
          ];
        in
        with pkgs; {
        default = mkShell {
          packages = [
            # Recommended package manager
            pixi
          ] ++ lib.optionals isLinux ([
            # CUDA packages only for Linux
            gcc13
          ] ++ cudaPackages);

          shellHook = lib.optionalString isLinux ''
            export CUDA_PATH=${pkgs.cudatoolkit}

            # Set CC to GCC 13 to avoid the version mismatch error
            export CC=${pkgs.gcc13}/bin/gcc
            export CXX=${pkgs.gcc13}/bin/g++
            export PATH=${pkgs.gcc13}/bin:$PATH

            # Add necessary paths for dynamic linking
            export LD_LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath ([
                "/run/opengl-driver" # Needed to find libGL.so
              ] ++ cudaPackages)
            }:$LD_LIBRARY_PATH

            # Set LIBRARY_PATH to help the linker find the CUDA static libraries
            export LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath [
                pkgs.cudatoolkit
              ]
            }:$LIBRARY_PATH

          '' + ''
            export MODULAR_TELEMETRY_ENABLED=0
            export MOJO_ENABLE_STACK_TRACE_ON_ERROR=1

            echo "Mojo Jojo ready!!!"
          '';
        };
      });
    };
}
