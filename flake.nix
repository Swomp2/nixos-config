{
  description = "Моя конфигурация NixOS";

  inputs = {
    # Добавление репозиториев
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Добавление модуля для декларативной разметки дисков
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Добавление модуля для управлением конфигами в домашней директории
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Добавление модуля для поддержки secureboot и разблокировки диска по tpm
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager, lanzaboote, ... }@inputs:
    let
      # Объявление общесистемных переменных
      system = "x86_64-linux";
      username = "swomp";
      homeDir = "/home/${username}";

      # Простая обёртка для нестабильных пакетов
      unstable = import inputs.nixpkgs-unstable {
        inherit system;

        # Разрешение на установку несвободных компонентов для стима
        config.allowUnfreePredicate = pkg: 
          builtins.elem (nixpkgs.lib.getName pkg) [
            "steam"
            "steam-unwrapped"
            "steam-run"
            "steam-cmd"
            "corefonts"
          ];
      };
 	  
      # Эта функция нужна, чтобы не писать каждый раз 
      # руками одинаковые конфигурации системы для 
      # разных устройств
      mkHost = { hostPath, homeImports, extraModules ? [ ] }:
        
        nixpkgs.lib.nixosSystem {
          inherit system;

          # Передача переменных во все модули
          # То есть в любом файле, кроме home, disko
          # Можно использовать так:
          # {username, inputs, unstable, homeDir, ...}:
          # И дальше уже сам модуль
          specialArgs = {
            inherit inputs username homeDir unstable homeImports;
          };

          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.default
            hostPath

            ./modules/users.nix               # Тут идёт вся общесистемная конфигурация пользователей
            ./modules/system-home-manager.nix # Тут общесистемная конфигурация home-manager
            
          ] ++ extraModules;
        };

        mkHome = { homeImports }:
          home-manager.lib.homeManagerConfiguration {
            # Объявление переменной pkgs тут нужно из-за
            # того, что pkgs не существует в этом модуле.
            # В mkHost уже используется nixpgs.lib.nixosSystem,
            # следовательно там не надо объявлять pkgs.
            # Тут надо.
            # То же самое с unstable
            pkgs = import inputs.nixpkgs {
              inherit system;
            };

            unstable = import inputs.nixpkgs-unstable {
              inherit system;
            };

          	extraSpecialArgs = {
              inherit inputs username homeDir unstable homeImports;
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
