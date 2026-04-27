{
  description = "HexProxy Nix Flake for Production Deployment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/0726a0e"; # April 22nd Pin
    # We pull the source directly here:
    hexproxy-source = {
      url = "github:Secure-Hex/HexProxy";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, hexproxy-source, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python313.withPackages (ps: with ps; [
	      packaging  # <--- Missing dependency detected
	      brotli     # <--- Required for high-performance proxying
        pip
      ]);
    in {
	    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ pythonEnv pkgs.openssl ]; 
        shellHook = ''
		      export HEXPROXY_SRC="${hexproxy-source}"
		      export PYTHONPATH="$HEXPROXY_SRC/src:$PYTHONPATH"
		      echo "--- HexProxy Ready for Activation ---"
		    '';
	};
     };
}
