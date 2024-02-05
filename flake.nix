{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      overlay = final: prev:
        {
          lua = prev.lua.override {
            packageOverrides = self: super: {
              gumbo = self.buildLuarocksPackage rec {
                pname = "gumbo";
                version = "0.5-1";
                src = final.fetchurl {
                  url = "mirror://luarocks/${pname}-${version}.src.rock";
                  sha256 = "0p36d63bjckn36yv9jly08igqjkx7xicq4q479f69njiaxlhag6f";
                };
                sourceRoot = "${pname}-${version}/lua-${pname}-0.5";
                disabled = self.luaOlder "5.1";
                propagatedBuildInputs = [ final.lua ];
              };
            };
          };
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            vim-vint
          ] ++ (with lua.pkgs; [
            fennel
            readline
            luasocket
            gumbo
          ]);
        };
      });
}
