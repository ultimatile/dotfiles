{
  description = "neovim-nightly-overlay";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = { nixpkgs, neovim-nightly-overlay, ... }:
  {
    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.stdenv.mkDerivation {
      name = "nvim-nightly";
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        ln -s ${neovim-nightly-overlay.packages.aarch64-darwin.neovim}/bin/nvim $out/bin/nvim-nightly
      '';
    };
  };
}

