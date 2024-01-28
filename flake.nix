{
  description = "A configuration flake for chinchilla-related deployments";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, disko, ... }:
    let
      configRevision = {
        full = self.rev or self.dirtyRev or "dirty-inputs";
        short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
      };
    in
    {
      nixosConfigurations = {
        makoto = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configRevision; };
          modules = [ ./hosts/makoto/configuration.nix ];
        };
        shiny = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configRevision; };
          modules = [ ./hosts/shiny/configuration.nix ];
        };
        uppie = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configRevision; };
          modules = [ ./hosts/uppie/configuration.nix ];
        };
      };
    };
}
