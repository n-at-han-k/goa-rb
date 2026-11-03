{
  description = "goa — Ruby bindings for GNOME Online Accounts, from its GI typelib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    mine.url = "github:n-at-han-k/flake.nix";
    mine.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, mine, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = mine.lib.${system};

        gemspecFiles = pkgs.runCommand "goa-gemspec" { } ''
          mkdir -p $out/lib/goa
          cp ${./goa.gemspec}         $out/goa.gemspec
          cp ${./lib/goa/version.rb}  $out/lib/goa/version.rb
        '';

        gems = pkgs.bundlerEnv {
          name = "goa-gems";
          ruby = pkgs.ruby_3_4;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = import ./gemset.nix;
          extraConfigPaths = [ "${gemspecFiles}/." ];
        };

        # The namespaces the loader needs at require time: Goa itself, plus
        # the GLib/GObject/Gio typelibs Goa-1.0.typelib declares as
        # dependencies and which the loader resolves transitively. Without
        # glib's directory here the load fails with
        #   Typelib file for namespace 'Gio' not found
        #
        # `makeSearchPath` would take each package's *first* output, and
        # `pkgs.glib`'s first output is `bin`, which carries no typelibs at
        # all -- hence the explicit `.out`. That trap has cost real time more
        # than once.
        typelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0"
          (map (drv: drv.out or drv) [ pkgs.gnome-online-accounts pkgs.glib ]);
      in
      {
        devShells.default = lib.mkRubyShell {
          buildInputs = with pkgs; [
            gems
            gems.wrappedRuby

            # GNOME Online Accounts, for Goa-1.0.typelib. Taking it from the
            # same nixpkgs as the gobject-introspection gem is not a tidiness
            # point: a typelib built against a different glib registers GIO a
            # second time in the process and dies with
            #   cannot register existing type 'GTlsCertificate'
            gnome-online-accounts

            skywalking-eyes
          ];

          shellHook = /* bash */ ''
            # Goa-1.0.typelib, plus the typelibs it depends on.
            export GI_TYPELIB_PATH="${typelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"

            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false

            export LANG="''${LANG:-C.UTF-8}"
            export LC_ALL="''${LC_ALL:-$LANG}"

            export RUBYLIB="$PWD/lib''${RUBYLIB:+:$RUBYLIB}"
          '';
        };
      }
    );
}
