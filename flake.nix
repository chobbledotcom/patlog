{
  description = "PAT Inspection Logger development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # ruby_3_4 in the pinned nixpkgs predates the CVE-2026-132825 fix
        # (Ruby 3.4.13), and nixpkgs still ships 3.4.12, so pin the fixed
        # patch release until it is available upstream.
        ruby = pkgs.ruby_3_4.overrideAttrs (old: {
          version = "3.4.13";
          src = pkgs.fetchurl {
            url = "https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.13.tar.gz";
            hash = "sha256-0NO/PdjCJKPDt+zYFqDxssvPT4e1r8vb6R0/7xd/NRo=";
          };
        });
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ruby
            rubyPackages_3_4.ruby-vips
            rubyPackages_3_4.psych
            sqlite
            nodejs
            imagemagick
          ];

          # Use bundler to manage Rails version instead of Nix
          shellHook = ''
            export GEM_HOME=$PWD/.gems
            export PATH=$GEM_HOME/bin:$PATH
            echo "Installing dependencies from Gemfile..."
            gem install bundler
            bundle install
            echo "Ruby $(ruby --version) with Rails $(rails --version)"
          '';
        };
      }
    );
}
