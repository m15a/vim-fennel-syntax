{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-tools = {
      url = "github:m15a/flake-fennel-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      fennel-tools,
      ...
    }:
    let
      overlay = final: prev: {
        fennel-luajit = prev.fennel-luajit.override {
          lua = prev.luajit.override {
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
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            fennel-tools.overlays.default
            overlay
          ];
        };
      in
      {
        devShells.default =
          let
            fennel = pkgs.fennel-lua5_3;
          in
          pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                nixfmt-rfc-style
                vim-vint
                fennel
                fennel-ls-unstable
              ]
              ++ (with fennel.lua.pkgs; [
                readline
                luasec
                gumbo
              ]);
            FENNEL_PATH = "./?.fnl;./?/init.fnl;./tools/?.fnl;./tools/?/init.fnl";
            FENNEL_MACRO_PATH = "./?.fnl;./?/init-macros.fnl;./tools/?.fnl;./tools/?/init-macros.fnl";
          };
      }
    );
}
