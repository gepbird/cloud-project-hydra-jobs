{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      hydraJobs = {
        # take the minikube package from nixpkgs and expose it as a hydra job
        minikube = pkgs.minikube;

        # a package that will always fail to build
        failing-package = pkgs.stdenv.mkDerivation {
          name = "failing-package";
          phases = [ "buildPhase" ];
          buildPhase = ''
            echo "This package is intentionally failing."
            exit 1
          '';
        };

        # modified docker where we add a custom message to the end of the `docker --help` command
        # and apply a patch from an arbitrary pull request
        docker = pkgs.docker.overrideAttrs {
          preBuild = ''
            substituteInPlace "cli/cobra.go" --replace-fail \
              "For more help on how to use Docker, head to https://docs.docker.com/go/guides/" \
              "For more help on how to use Docker, head to https://docs.docker.com/go/guides/\nThis version of docker is modified and was build on Hydra."
          '';
          patches = [
            (pkgs.fetchpatch {
              # https://github.com/docker/cli/pull/6048
              name = "enhance-docker-system-prune-performance-via-concurrent-pruning.patch";
              url = "https://github.com/docker/cli/pull/6048/commits/255b625672a85506d4a5782c4e250175d307ee45.patch";
              hash = "sha256-Az9P/6SmSBtykE4gQNTG0H8MHqqb4CpQyYg468q42KA=";
            })
          ];
        };
      };
    };
}
