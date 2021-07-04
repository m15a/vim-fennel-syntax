let
  lock = {
    nixpkgs = {
      rev = "51bb9f3e9ab6161a3bf7746e20b955712cef618b";
      sha256 = "1bqla14c80ani27c7901rnl37kiiqrvyixs6ifvm48p5y6xbv1p7";
    };
  };

  nixpkgs = with lock.nixpkgs;
  builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
  };

  pkgs = import nixpkgs {};

  lua = pkgs.luajit.override {
    packageOverrides = self: super: {
      fennel = self.buildLuarocksPackage rec {
        pname = "fennel";
        version = "2e0ce2e21198a6aae1b2fc8d7e4b8a7d7d3ab11b";
        src = pkgs.fetchFromGitHub {
          owner = "bakpakin";
          repo = "Fennel";
          rev = version;
          sha256 = "1724g9rkqh2l93jz9jjpjydn2c1lfws44qigpvlkyi14g0gf7dfq";
        };
        knownRockspec = "${src}/rockspecs/fennel-scm-2.rockspec";
        disabled = self.luaOlder "5.1";
        propagatedBuildInputs = [ lua ];
      };
      gumbo = self.buildLuarocksPackage rec {
        pname = "gumbo";
        version = "0.5-1";
        src = pkgs.fetchurl {
          url    = "mirror://luarocks/${pname}-${version}.src.rock";
          sha256 = "0p36d63bjckn36yv9jly08igqjkx7xicq4q479f69njiaxlhag6f";
        };
        disabled = self.luaOlder "5.1";
        propagatedBuildInputs = [ lua ];
      };
    };
  };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    vim-vint
  ] ++ (with lua.pkgs; [
    fennel
    # readline
    luasocket
    gumbo
  ]);
}
