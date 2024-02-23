{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-tools = {
      url = "github:m15a/flake-fennel-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fennel-tools, ... }:
    let
      overlay = final: prev:
        {
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
    flake-utils.lib.eachDefaultSystem (system:
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
            fennel = pkgs.fennel-luajit;
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              vim-vint
              fennel
            ] ++ (with fennel.lua.pkgs; [
              readline
              luasec
              gumbo
            ]);
            FENNEL_PATH = "./_fnl/?.fnl;./_fnl/?/init.fnl";
            FENNEL_MACRO_PATH = "./_fnl/?.fnl;./_fnl/?/init.fnl";
          };
      });
}
