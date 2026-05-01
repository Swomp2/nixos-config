{username, homeDir, inputs, unstable, homeImports, ...}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Включение бэкапов файлов в домашней директории
    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit inputs username homeDir unstable homeImports;
    };

    users.${username} = {
        imports = homeImports;

        home.username = username;
        home.homeDirectory = homeDir;
        home.stateVersion = "25.11";
    };
  };
}