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

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager, lanzaboote, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "swomp";
      homeDir = "/home/${username}";

	  unstable = import inputs.nixpkgs-unstable {
	  	inherit system;
	  	config = {
	  	  allowUnfreePredicate = pkg: 
	  	    builtins.elem (nixpkgs.lib.getName pkg) [
	  	  	  "steam"
	  	  	  "steam-unwrapped"
	  	  	  "steam-run"
	  	  	  "steam-cmd"
	  	  	  "corefonts"
	  	    ];
	  	};
	  };
 	  
      mkHost =
        { hostPath
        , homeImports
        , extraModules ? [ ]
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs username homeDir unstable;
          };

          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.default
            hostPath

            ({ pkgs, ... }: {

              users.mutableUsers = false;

              users.users.${username} = {
                isNormalUser = true;
                description = "Swomp";
                home = homeDir;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                  "audio"
                  "video"
                  "gamemode"
                ];
                shell = pkgs.fish;
              };

              users.users.root.hashedPassword = "!";

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                # Включение бэкапов файлов в домашней директории
                backupFileExtension = "backup";

                extraSpecialArgs = {
                  inherit inputs username homeDir unstable;
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

        mkHome = 
          { homeImports }:
          home-manager.lib.homeManagerConfiguration {
          	pkgs = import nixpkgs {
          	  inherit system;
          	  config.allowUnfree = true;
          	};
          	extraSpecialArgs = {
              inherit inputs username homeDir unstable;
          	};

          	modules = homeImports ++ [
          	  {
          	  	home.username = username;
          	  	home.homeDirectory = homeDir;
          	  	home.stateVersion = "25.11";
          	  }
          	];
          };
    in {
      homeConfigurations = {
      	pc = mkHome {
      	  homeImports = [
      	  	./home/pc.nix
      	  	./home/common.nix
      	  ];
      	};

      	laptop = mkHome {
      	  homeImports = [
      	  	./home/laptop.nix
      	  	./home/common.nix
      	  ];
      	};
      };
      
      nixosConfigurations = {
        pc = mkHost {
          hostPath = ./hosts/pc/configuration.nix;
          homeImports = [
            ./home/pc.nix
            ./home/common.nix
          ];

          extraModules = [
            {
              users.users.${username}.hashedPassword = "$y$j9T$3wXS1qCIBpSmkvHf/s6mn.$IzM1ZoDQufoR.5wS/lLKZD.f1k8b/Nyj1J/hHYwsgp1";
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
              users.users.${username}.hashedPassword = "$y$j9T$Q2r6j1dZlRGIHYVnhXk4T.$FBGNdh1hckjNonKRcCruXa41vtB/2s.i9Lg8QktABg4";
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
