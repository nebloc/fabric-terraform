
{
  description = "A terraform deployment environment with Azure CLI";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux"; # Change to your system if needed
    pkgs = import nixpkgs {
      config.allowUnfree = true; # Allow unfree packages if needed
      inherit system;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        terraform
        azure-cli
      ];

      shellHook = '''';
    };
  };
}
