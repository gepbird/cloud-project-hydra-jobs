{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            docker = prev.docker.overrideAttrs (old: {
              patches = [
                (prev.fetchpatch {
                  # https://github.com/docker/cli/pull/6048
                  name = "enhance-docker-system-prune-performance-via-concurrent-pruning.patch";
                  url = "https://github.com/docker/cli/pull/6048/commits/255b625672a85506d4a5782c4e250175d307ee45.patch";
                  hash = "sha256-Az9P/6SmSBtykE4gQNTG0H8MHqqb4CpQyYg468q42KA=";
                })
              ];
              preBuild = ''
                substituteInPlace "cli/cobra.go" --replace-fail \
                  "For more help on how to use Docker, head to https://docs.docker.com/go/guides/" \
                  "For more help on how to use Docker, head to https://docs.docker.com/go/guides/\nThis version of docker is modified and was build on Hydra."
              '';
            });
            failing-package = prev.stdenv.mkDerivation {
              name = "failing-package";
              dontUnpack = true;
              buildPhase = ''
                echo "This package is intentionally failing"
                exit 1
              '';
            };
          })
        ];
      };
    in
    {
      hydraJobs = {
        inherit (pkgs)
          minikube
          docker
          failing-package
          ;
      };
    };
}
