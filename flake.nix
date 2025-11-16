{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
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
      };
    in
    {
      devShells = forDefaultSystems (pkgs: rec {
        formatting = pkgs.mkShell {
          packages = with pkgs; [
            vim-vint
          ];
        };
        default = pkgs.mkShell {
          inputsFrom = [ formatting ];
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
