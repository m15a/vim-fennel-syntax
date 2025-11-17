{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      pname = "vim-fennel-syntax";
      version = "${version_base}+sha.${version_sha}";
      version_base = "1.2.0";
      version_sha = self.shortRev or self.dirtyShortRev or "unknown";

      defaultSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forDefaultSystems =
        f:
        nixpkgs.lib.genAttrs defaultSystems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ overlay ];
            }
          )
        );

      overlay = final: prev: {
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

        m15aVimPlugins =
          with final.lib;
          makeExtensible (
            _:
            recurseIntoAttrs {
              ${pname} = final.vimUtils.buildVimPlugin {
                inherit pname version;
                src = ./.;
                meta = {
                  description = "Yet another Vim syntax highlighting plugin for Fennel";
                  license = licenses.mit;
                  homepage = "https://github.com/m15a/${pname}";
                };
              };
            }
          );

        formatter = final.writeShellApplication {
          name = "${pname}-formatter";
          runtimeInputs = with final; [
            nixfmt-rfc-style
            vim-vint
          ];
          text = ''
            mapfile -t files < <(git ls-files --exclude-standard)
            for file in "''${files[@]}"; do
                case "''${file##*.}" in
                    nix)
                        nixfmt -w80 "$file"
                        ;;
                    vim)
                        vint "$file"
                        ;;
                esac
            done
          '';
        };
      };
    in
    {
      overlays.default = final: prev: {
        inherit (overlay final prev) m15aVimPlugins;
      };

      packages = forDefaultSystems (pkgs: {
        default = pkgs.m15aVimPlugins.${pname};
      });

      checks = forDefaultSystems (pkgs: {
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

      formatter = forDefaultSystems (pkgs: pkgs.formatter);

      devShells = forDefaultSystems (pkgs: {
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
