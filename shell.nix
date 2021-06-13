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
        version = "0.9.2";
        knownRockspec = "${src}/rockspecs/fennel-scm-2.rockspec";
        src = pkgs.fetchFromGitHub {
          owner = "bakpakin";
          repo = "Fennel";
          rev = version;
          sha256 = "1kpm3lzxzwkhxm4ghpbx8iw0ni7gb73y68lsc3ll2rcx0fwv9303";
        };
        disabled = (self.luaOlder "5.1");
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
    readline
  ]);
}
