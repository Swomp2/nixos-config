{ ... }:
{
  # Импорты всех файлов с настройками контейнеров
  imports = [
    ./docker/postgres.nix
    ./docker/redis.nix
    ./docker/nextcloud.nix
    ./docker/pihole.nix
    ./docker/clipcascade.nix
    ./docker/coturn.nix
    ./docker/synapse.nix
    ./docker/collabora.nix
  ];

  virtualisation.docker = {
    enable = true;

    daemon.settings = {
      data-root = "/srv/docker"; # Тут будут храниться данные контейнеров
      log-driver = "journald"; # Это чтобы логи не копились json файлами
    };

    # Чистка неиспользуемого мусора раз в неделю
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Контейнеры из virtualisation.oci-containers.containers.* запускать через Docker
  virtualisation.oci-containers = {
    backend = "docker";
  };

  systemd.tmpfiles.rules = [
    "d /srv/docker 0711 root root -"
    "d /srv/backups 0750 root root -"
  ];
}
