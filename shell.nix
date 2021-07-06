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
        version = "1625c3122199d930858e91de9f601ccc202c5cc0";
        src = pkgs.fetchFromGitHub {
          owner = "bakpakin";
          repo = "Fennel";
          rev = version;
          sha256 = "08r06vj88kp30q48ln26fksy09f4hl3kdkbnvbgl2w1wzz6vryi6";
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
