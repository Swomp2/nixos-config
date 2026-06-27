{
  description = "Моя конфигурация NixOS";

  inputs = {
    # Добавление репозиториев
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Модуль для декларативной установки flatpak пакетов
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    # Версия hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.55.4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Версия плагина курсоров для hyprland
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors/da447486c84e0be81f2cdd208af1ef92469f0a88";
      inputs.hyprland.follows = "hyprland";
    };

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    # Добавление модуля для декларативной разметки дисков
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Добавление модуля для управлением конфигами в домашней директории
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Добавление модуля для поддержки secureboot и разблокировки диска по tpm
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      lanzaboote,
      nix-flatpak,
      ...
    }@inputs:
    let
      # Объявление общесистемных переменных
      system = "x86_64-linux";
      username = "swomp";
      homeDir = "/home/${username}";
      timeZone = "Europe/Moscow";
      theme = import ./theme.nix;

      allowUnfreePredicate =
        pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "steam"
          "steam-unwrapped"
          "steam-run"
          "steamcmd"
          "corefonts"
        ];

      pkgsStable = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };

      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };

      # Эта функция нужна, чтобы не писать каждый раз
      # руками одинаковые конфигурации системы для
      # разных устройств
      mkHost =
        {
          hostPath,
          extraModules ? [ ],
        }:

        nixpkgs.lib.nixosSystem {
          inherit system;

          # Передача переменных во все модули
          # То есть в любом файле, кроме home, disko
          # Можно использовать так:
          # {username, inputs, unstable, homeDir, ...}:
          # И дальше уже сам модуль
          specialArgs = {
            inherit
              inputs
              username
              homeDir
              timeZone
              unstable
              theme
              ;
          };

          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            hostPath

            ./modules/users.nix # Тут идёт вся общесистемная конфигурация пользователей

          ]
          ++ extraModules;
        };

      mkServer =
        {
          hostPath,
          extraModules ? [ ],
        }:

        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit
              inputs
              username
              homeDir
              timeZone
              unstable
              theme
              ;
          };

          modules = [
            {
              nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
            }

            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            hostPath

            ./modules/server/users.nix # Тут идёт вся общесистемная конфигурация пользователей для сервера
          ]
          ++ extraModules;
        };

      mkHome =
        { homeImports }:
        home-manager.lib.homeManagerConfiguration {
          # Объявление переменной pkgs тут нужно из-за
          # того, что pkgs не существует в этом модуле.
          # В mkHost уже используется nixpgs.lib.nixosSystem,
          # следовательно там не надо объявлять pkgs.
          # Тут надо.
          # То же самое с unstable
          pkgs = pkgsStable;

          extraSpecialArgs = {
            inherit
              inputs
              username
              homeDir
              timeZone
              unstable
              homeImports
              theme
              ;
          };

          modules = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.nixvim.homeModules.nixvim
          ]
          ++ homeImports
          ++ [
            {
              home.username = username;
              home.homeDirectory = homeDir;
              home.stateVersion = "25.11";
            }
          ];
        };
    in
    {
      formatter.${system} = pkgsStable.nixfmt-tree;

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

          extraModules = [
            {
              users.users.${username}.hashedPassword =
                "$y$j9T$3wXS1qCIBpSmkvHf/s6mn.$IzM1ZoDQufoR.5wS/lLKZD.f1k8b/Nyj1J/hHYwsgp1";
            }
          ];
        };

        laptop = mkHost {
          hostPath = ./hosts/laptop/configuration.nix;

          extraModules = [
            {
              users.users.${username}.hashedPassword =
                "$y$j9T$Q2r6j1dZlRGIHYVnhXk4T.$FBGNdh1hckjNonKRcCruXa41vtB/2s.i9Lg8QktABg4";
            }
          ];
        };

        server = mkServer {
          hostPath = ./hosts/server/configuration.nix;

          extraModules = [
            {
              users.users.${username}.hashedPassword =
                "$y$j9T$VviH8YXVGoXdN.aLmCW8k0$5WUGOc854Zre7TPLD/JdqBCpqk5NwqPQD94DSdbJTEB";
            }
          ];
        };
      };
    };
}
