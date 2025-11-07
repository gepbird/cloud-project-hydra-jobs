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
              postFixup = (old.postFixup or "") + ''
                touch $out/1
              '';
            });
          })
        ];
      };
    in
    {
      hydraJobs = {
        inherit (pkgs) minikube docker;
      };
    };
}
