{pkgs, ...}:
{
  systemd.services.prepare-nextcloud-storage = {
  	description = "Подготовка директорий nextcloud";
  	wantedBy    = [ "multi-user.target" ];

  	path = [
  	  pkgs.coreutils
  	];

  	serviceConfig = {
  	  Type            = "oneshot";
  	  RemainAfterExit = true;
  	};

  	script = ''
  	  set -eu
  	
      mkdir -p /srv/nextcloud/html
      mkdir -p /srv/nextcloud/config
      mkdir -p /srv/nextcloud/custom_apps
      mkdir -p /srv/nextcloud/data
      mkdir -p /srv/nextcloud/themes

      chown -R 33:33 /srv/nextcloud
      chmod 0750 /srv/nextcloud
      chmod 0750 /srv/nextcloud/html
      chmod 0750 /srv/nextcloud/config
      chmod 0750 /srv/nextcloud/custom_apps
      chmod 0750 /srv/nextcloud/data
      chmod 0750 /srv/nextcloud/themes
  	'';
  };

  virtualisation.oci-containers.containers.nextcloud = {
  	image     = "nextcloud:33.0.4-fpm"
  	autoStart = true;

  	ports = [
  	  "127.0.0.1:9000:9000"
  	];

  	volumes = [
  	  "/srv/nextcloud/html:/var/www/html"
  	  "/srv/nextcloud/config:/var/www/html/config"
  	  "/srv/nextcloud/custom_apps:/var/www/html/custom_apps"
  	  "/srv/nextcloud/data:/var/www/html/data"
  	  "/srv/nextcloud/themes:/var/www/html/themes"

  	  "/srv/secrets/postgres-nextcloud-password:/run/secrets/postgres-nextcloud-password:ro"
  	  "/srv/secrets/nextcloud-admin-password:/run/secrets/nextcloud-admin-password:ro"
  	];
  };
}
