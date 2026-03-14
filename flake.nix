{
  description = "Моя конфигурация NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, disko, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "swomp";
      homeDir = "/home/${username}";

      mkHost =
        { hostPath
        , homeImports
        , extraModules ? [ ]
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs username homeDir;
          };

          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.default
            hostPath

            ({ pkgs, ... }: {

              users.mutableUsers = true;

              users.users.${username} = {
                isNormalUser = true;
                description = "Swomp";
                home = homeDir;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                  "audio"
                  "video"
                ];
                shell = pkgs.fish;
              };

              users.users.root.hashedPassword = "!";

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                extraSpecialArgs = {
                  inherit inputs username homeDir;
                };

                users.${username} = {
                  imports = homeImports;

                  home.username = username;
                  home.homeDirectory = homeDir;
                  home.stateVersion = "25.11";
                };
              };
            })
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        pc = mkHost {
          hostPath = ./hosts/pc/configuration.nix;
          homeImports = [
            ./home/pc.nix
            ./home/common.nix
          ];

          extraModules = [
            {
              users.users.${username}.initialPassword = "swomp";
            }
          ];
        };

        laptop = mkHost {
          hostPath = ./hosts/laptop/configuration.nix;
          homeImports = [
            ./home/laptop.nix
            ./home/common.nix
          ];

          extraModules = [
            {
              users.users.${username}.initialPassword = "swomp";
            }
          ];
        };

        vm = mkHost {
          hostPath = ./hosts/vm/configuration.nix;
          homeImports = [
            ./home/vm.nix
            ./home/common.nix
          ];

          extraModules = [
            {
              users.users.${username}.initialPassword = "swomp";
            }
          ];
        };
      };
    };
}
