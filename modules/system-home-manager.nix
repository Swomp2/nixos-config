{
  username,
  homeDir,
  timeZone,
  inputs,
  unstable,
  homeImports,
  theme,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Включение бэкапов файлов в домашней директории
    backupFileExtension = "backup";

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

    users.${username} = {
      imports = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ]
      ++ homeImports;

      home.username = username;
      home.homeDirectory = homeDir;
      home.stateVersion = "25.11";
    };
  };
}
