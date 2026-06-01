{...}:
{
  virtualisation.docker = {
  	enable = true;

  	daemon.settings = {
  	  data-root = "/srv/docker"; # Тут будут храниться данные контейнеров
  	  log-driver = "journald";   # Это чтобы логи не копились json файлами
  	};

	# Чистка неиспользуемого мусора раз в неделю
  	autoPrune = {
  	  enable = true;
  	  dates  = "weekly";
  	};
  };

  # Контейнеры из virtualisation.oci-containers.containers.* запускать через Docker
  virtualisation.oci-containers = {
  	backend = "docker";
  };

  systemd.tmpfiles.rules = [
  	"d /srv/docker 0711 root root -"
  	"d /srv/secrets 0700 root root -"

  	"d /srv/nextcloud 0750 root root -"
  	
  	"d /srv/synapse 0750 root root -"
  	"d /srv/synapse/workers 0750 root root -"
  	
  	"d /srv/postgres 0750 root root -"
  	"d /srv/postgres/nextcloud 0750 root root -"
  	"d /srv/postgres/synapse 0750 root root -"
  	
  	"d /srv/redis 0750 root root -"
  	"d /srv/redis/nextcloud 0750 root root -"
  	"d /srv/redis/synapse 0750 root root -"
  	
  	"d /srv/clipcascade 0750 root root -"
  	"d /srv/backups 0750 root root -"
  ];
}
