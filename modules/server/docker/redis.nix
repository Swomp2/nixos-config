{pkgs, ...}:
let
  redisUid = "999";
  redisGid = "1000";
in
{
  systemd.tmpfiles.rules = [
    "d /srv/redis 0755 root root -"
    "d /srv/redis/nextcloud 0755 ${redisUid} ${redisGid} -"
    "d /srv/redis/synapse 0755 ${redisUid} ${redisGid} -"
  ];

  virtualisation.oci-containers.containers = {
    # Контейнер redis для nextcloud
  	redis-nextcloud = {
  	  image = "redis:7-alpine"; # Образ redis, рантайм от alpine
  	  autoStart = true;         # Автозагрузка при включении сервера

  	  volumes = [
  	  	"/srv/redis/nextcloud:/data" # До ":" путь на сервере, после путь внутри контейнера 
  	  ];

      # Команда запуска redis
      # Она говорит redis писать все данные в журнал, чтобы если сервер
      # резко выключится, все данные остались в целости и сохранности
  	  cmd = [
  	  	"redis-server"
  	  	"--appendonly"
  	  	"yes"
  	  ];

  	  extraOptions = [
  	  	"--network=server-net" # Подключение контейнера к server-net, чтобы другие контейнеры могли с ним взаимодействовать
  	  	"--network-alias=redis-nextcloud"
  	  ];
  	};

  	# Контейнер redis для воркеров synapse
  	redis-synapse = {
  	  image = "redis:7-alpine"; # Образ redis, рантайм от alpine
  	  autoStart = true;         # Автозагрузка при включении сервера

  	  volumes = [
  	  	"/srv/redis/synapse:/data" # До ":" путь на сервере, после путь внутри контейнера
  	  ];

      # Команда запуска redis
      # Она говорит redis писать все данные в журнал, чтобы если сервер
      # резко выключится, все данные остались в целости и сохранности
  	  cmd = [
  	  	"redis-server"
  	  	"--appendonly"
  	  	"yes"
  	  ];

  	  extraOptions = [
  	  	"--network=server-net"# Подключение контейнера к server-net, чтобы другие контейнеры могли с ним взаимодействовать
  	  	"--network-alias=redis-synapse"
  	  ];
  	};
  };

  # Юнит для создания сети для docker контейнеров
  systemd.services.init-server-net = {
  	description = "Создание docker сети для серверных контейнеров";
  	after       = [ "docker.service" ];
  	requires    = [ "docker.service" ];
  	wantedBy    = [ "multi-user.target" ];

  	serviceConfig = {
  	  Type = "oneshot";
  	  RemainAfterExit = true;
  	};

  	script = ''
  	  ${pkgs.docker}/bin/docker network inspect server-net >/dev/null 2>&1 \
  	    || ${pkgs.docker}/bin/docker network create server-net
  	'';
  };

  # Запуск юнита redis контейнера для nextcloud
  systemd.services.docker-redis-nextcloud = {
  	after    = [ "init-server-net.service" ];
  	requires = [ "init-server-net.service" ];
  };

  # Запуск юнита redis контейнера для synapse
  systemd.services.docker-redis-synapse = {
   	after    = [ "init-server-net.service" ];
  	requires = [ "init-server-net.service" ];
  };
}
