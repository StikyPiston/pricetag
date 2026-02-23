{
  description = "pricetag devshell and package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "pricetag-devshell";

          packages = with pkgs; [
            go
            gopls
            gotools
            delve
          ];
        };

        packages.pricetag = pkgs.buildGoModule {
          pname = "pricetag";
          version = "2026.02.23-a";

          src = self;

          vendorHash = "sha256-FBb8RFndx6wwdu08B95d+qas4VWs6Vr7UrXVGLyCW0g=";

          subPackages = [ "." ];
          ldflags = [ "-s" "-w" ];

          meta = with pkgs.lib; {
            description = "A CLI file tagging solution";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };

        apps.pricetag = {
          type = "app";
          program = "${self.packages.${system}.pricetag}/bin/pricetag";
        };
      });
}
