{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      pname = "vim-fennel-syntax";

      version = "${version_base}+sha.${version_sha}";
      version_base = "1.3.0";
      version_sha = self.shortRev or self.dirtyShortRev or "unknown";

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [
                devOverlay
                overlay
              ];
            }
          )
        );

      devOverlay = final: prev: {
        luajit = prev.luajit.override {
          packageOverrides = self: super: {
            gumbo = self.buildLuarocksPackage rec {
              pname = "gumbo";
              version = "0.5-1";
              src = final.fetchurl {
                url = "mirror://luarocks/${pname}-${version}.src.rock";
                sha256 = "0p36d63bjckn36yv9jly08igqjkx7xicq4q479f69njiaxlhag6f";
              };
              sourceRoot = "${pname}-${version}/lua-${pname}-0.5";
              propagatedBuildInputs = [ final.luajit ];
            };
          };
        };
        formatter = final.writeShellApplication {
          name = "${pname}-formatter";
          runtimeInputs = with final; [
            vim-vint
            nixfmt-rfc-style
          ];
          text = ''
            mapfile -t files < <(git ls-files --exclude-standard)
            for file in "''${files[@]}"; do
                case "''${file##*.}" in
                    vim)
                        vint "$file" &
                        ;;
                    nix)
                        nixfmt -w80 "$file" &
                        ;;
                esac
            done
          '';
        };
      };

      overlay = final: prev: {
        m15aVimPlugins =
          let
            inherit (final) lib;
            super =
              prev.m15aVimPlugins or (lib.makeExtensible (_: lib.recurseIntoAttrs { }));
          in
          super.extend (
            _: _: {
              ${pname} = final.vimUtils.buildVimPlugin {
                inherit pname version;
                src = ./.;
                meta = {
                  description = "Yet another Vim syntax highlighting plugin for Fennel";
                  license = lib.licenses.mit;
                  homepage = "https://github.com/m15a/${pname}";
                };
              };
            }
          );
      };
    in
    {
      overlays.default = overlay;

      packages = forSystems (pkgs: {
        default = pkgs.m15aVimPlugins.${pname};
      });

      checks = forSystems (pkgs: {
        package = pkgs.m15aVimPlugins.${pname};

        formatting =
          pkgs.runCommandLocal "check-formatting"
            {
              buildInputs = [
                pkgs.gitMinimal
                pkgs.formatter
              ];
            }
            ''
              cp -r --no-preserve=mode ${self} source
              cd source
              git init --quiet && git add .
              ${pkgs.formatter.name}
              test $? -ne 0 && exit 1
              touch $out
            '';
      });

      formatter = forSystems (pkgs: pkgs.formatter);

      devShells = forSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (luajit.withPackages (
              ps: with ps; [
                fennel
                readline
                luasec
                gumbo
              ]
            ))
            fennel-ls
          ];
          FENNEL_PATH = "./?.fnl;./?/init.fnl;./tools/?.fnl;./tools/?/init.fnl";
          FENNEL_MACRO_PATH = "./?.fnl;./?/init-macros.fnl;./tools/?.fnl;./tools/?/init-macros.fnl";
        };
      });
    };
}
