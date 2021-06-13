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
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    vim-vint
  ];
}
