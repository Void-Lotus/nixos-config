{
  description = "Void Lotus NixOS Configuration Flake";

  nixConfig = {
    extra-substituters = [
      "https://nyx-cache.chaotic.cx"
    ];
    extra-trusted-public-keys = [
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachyos-niri-noctalia = {
      url = "github:cachyos/cachyos-niri-noctalia";
      flake = false;
    };

    nirimod = {
      url = "github:srinivasr/nirimod";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, chaotic, zen-browser, home-manager, noctalia, cachyos-niri-noctalia, agenix, ... }@inputs: {
    nixosConfigurations = {
      nixlotus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          chaotic.nixosModules.default
          noctalia.nixosModules.default
          ./modules/desktop/cachy-niri.nix
          ./configuration.nix
          ./hosts/nixlotus/hardware-configuration.nix
          ./hosts/nixlotus/default.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.voidlotus = import ./home.nix;
          }
        ];
      };
    };
  };
}
