{
  description = "A configuration flake for chinchilla-related deployments";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ nixpkgs, disko, ... }: {
    nixosConfigurations = {
      makoto = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/makoto/configuration.nix ];
      };
      uppie = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/uppie/configuration.nix ];
      };
    };
  };
}
