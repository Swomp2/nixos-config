{
  pkgs,
  username,
  homeDir,
  ...
}:
{
  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    description = "Swomp";
    home = homeDir;
    extraGroups = [
      "wheel"
      "docker"
      "systemd-journal"
    ];
    shell = pkgs.fish;
  };

  users.users.root.hashedPassword = "!";
}
