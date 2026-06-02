{ config, pkgs, ... }:

let
  domain = "cloud.swomp.ru";
  lanAddress = "192.168.1.244";

  nextcloudImage = "nextcloud:33.0.4-fpm-alpine";
  clamavImage = "clamav/clamav-debian:1.5.2_base";

  secretsDir = "/srv/secrets";

  nextcloudDir = "/srv/nextcloud";
  htmlDir = "${nextcloudDir}/html";
  dataDir = "${nextcloudDir}/data";
  appsDir = "${nextcloudDir}/custom_apps";
  phpDir = "${nextcloudDir}/php";

  clamavDir = "/srv/clamav";
  clamavDbDir = "${clamavDir}/db";
  
  clamavConfigDir = "${clamavDir}/config";

  backend = config.virtualisation.oci-containers.backend;
  dockerBin = "${config.virtualisation.docker.package}/bin/docker";

  nextcloudService = "${backend}-nextcloud";
  clamavService = "${backend}-clamav";

  nextcloudUnit = "${nextcloudService}.service";
  clamavUnit = "${clamavService}.service";
  postgresUnit = "${backend}-postgres-nextcloud.service";
  redisUnit = "${backend}-redis-nextcloud.service";

  nextcloudConfig = pkgs.writeText "server.config.php" ''
    <?php
    $CONFIG = array (

      'trusted_domains' => array (
        0 => 'cloud.swomp.ru',
        1 => '192.168.1.244',
        2 => 'localhost',
      ),

      'datadirectory' => '/srv/nextcloud/data',

      'dbtype' => 'pgsql',
      'dbname' => 'nextcloud',
      'dbhost' => 'postgres-nextcloud',
      'dbport' => '5432',
      'dbtableprefix' => 'oc_',
      'dbuser' => 'nextcloud',
      'dbpassword' => trim(file_get_contents('/run/secrets/postgres-nextcloud-password')),

      'forbidden_filename_characters' => array (
        0 => '\\',
        1 => '/',
      ),

      'forbidden_filename_extensions' => array (
        0 => '.filepart',
        1 => '.part',
      ),

      'defaultapp' => 'dashboard,calendar',

      # Доверенные прокси
      'trusted_proxies' => array (
        0 => '192.168.1.1/32', # Роутер
        1 => '127.0.0.1/32',   # Локальный IPv4
        2 => '::1/128',        # Локальный IPv6
        3 => '172.16.0.0/12',  # Docker сеть
      ),

      # Заголовки, по которым nextcloud понимает реальный IP клиента
      'forwarded_for_headers' => array (
        0 => 'HTTP_X_FORWARDED_FOR',
        1 => 'HTTP_FORWARDED',
      ),

      'overwritehost' => 'cloud.swomp.ru',
      'overwriteprotocol' => 'https',
      'overwrite.cli.url' => 'https://cloud.swomp.ru',
      'overwritewebroot' => '/',
      
      'loglevel' => 2, # Уровень логирования (писать warning и серьёзнее)

      # Кэш
      'memcache.local' => '\\OC\\Memcache\\APCu',    # Кэш через APCu, ускоряет nextcloud
      'memcache.locking' => '\\OC\\Memcache\\Redis', # Файловые блокировки через Redis

      # Настройки Redis
      'redis' => array (
        'host' => 'redis-nextcloud', # Имя контейнера в server-net
        'port' => 6379,
        'timeout' => 0.0,            # Отсутствие жёсткого короткого таймаута
        'dbindex' => 0,              # Логическая база Redis номер 0
      ),

      'default_phone_region' => 'RU',

      'appstoreenabled' => true,
      'appstoreurl' => 'https://apps.nextcloud.com/api/v1',
      'config_preset' => 1,

      # nextcloud управляет очисткой корзины. Очищается автоматически раз в 7 дней
      'trashbin_retention_obligation' => 'auto, 7',
      # Старые версии файлов тоже очищаются автоматически раз в 7 дней
      'versions_retention_obligation' => 'auto, 7',

      'twofactor_enforced' => false,

      'twofactor_enforced_groups' => array (
        0 => 'admin',
      ),

      'twofactor_enforced_excluded_groups' => array (
      ),

      # Обслуживание начинается в 2 часа ночи
      'maintenance_window_start' => 2,
    );
  '';

  # Конфиг для php связанным с nextcloud
  phpConfig = pkgs.writeText "server.ini" ''
    # Максимум памяти на php процесс
    memory_limit=1024M

    # Максимальный размер одного загружаемого файла
    upload_max_filesize=20G

    # Максимальный размер POST запроса
    post_max_size=20G

    # Таймаут сетевых операций php
    default_socket_timeout=600

    # Буфер interned strings для OPcache
    opcache.interned_strings_buffer=16
  '';

  # Небольшой конфиг для российского зеркала базы вирусов clamav
  freshclamConfig = pkgs.writeText "freshclam.conf" ''
    DatabaseDirectory /var/lib/clamav
    UpdateLogFile /dev/stdout
    LogTime yes

    DatabaseMirror https://mirror.truenetwork.ru/clamav
    DatabaseMirror database.clamav.net

    Checks 24
  '';
in
{
  # Создание директорий с нужными владельцами и правами
  systemd.tmpfiles.rules = [
    "d ${nextcloudDir} 0755 root root -"
    "d ${htmlDir} 0755 33 33 -"
    "d ${htmlDir}/config 0755 33 33 -"
    "d ${dataDir} 0750 33 33 -"
    "d ${appsDir} 0755 33 33 -"
    "d ${phpDir} 0755 root root -"
    "d ${phpDir}/conf.d 0755 root root -"

    "d ${clamavDir} 0755 root root -"
    "d ${clamavDbDir} 0755 root root -"
    "d ${clamavConfigDir} 0755 root root -"
  ];

  # Создание конфигов на диске в нужных директориях
  systemd.services.prepare-nextcloud-config = {
    description = "Подготовка конфигов nextcloud";
    wantedBy = [ "multi-user.target" ];

    after = [
      "init-server-secrets.service"
    ];

    requires = [
      "init-server-secrets.service"
    ];

    path = [
      pkgs.coreutils
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      install -d -m 0755 -o 33 -g 33 ${htmlDir}/config
      install -m 0640 -o 33 -g 33 ${nextcloudConfig} ${htmlDir}/config/server.config.php

      install -d -m 0755 -o root -g root ${phpDir}/conf.d
      install -m 0644 -o root -g root ${phpConfig} ${phpDir}/conf.d/server.ini
    '';
  };

  # Конфиг контейнера для clamav
  virtualisation.oci-containers.containers.clamav = {
    image = clamavImage;
    autoStart = true;

    volumes = [
      "${clamavDbDir}:/var/lib/clamav"
      "${freshclamConfig}:/etc/clamav/freshclam.conf:ro"
    ];

    environment = {
      CLAMD_STARTUP_TIMEOUT = "900";
    };

    extraOptions = [
      "--network=server-net"
      "--network-alias=clamav" # Имя clamav в docker сети
    ];
  };

  # Создание контейнера для nextcloud
  virtualisation.oci-containers.containers.nextcloud = {
    image = nextcloudImage;
    autoStart = true;

    ports = [
      "127.0.0.1:9000:9000"
    ];

    volumes = [
      "${htmlDir}:/var/www/html"
      "${dataDir}:/srv/nextcloud/data"
      "${appsDir}:/var/www/html/custom_apps"
      "${phpDir}/conf.d/server.ini:/usr/local/etc/php/conf.d/server.ini:ro"

      "${secretsDir}/postgres-nextcloud-password:/run/secrets/postgres-nextcloud-password:ro"

      "${secretsDir}/nextcloud-admin-password:/run/secrets/nextcloud-admin-password:ro"
    ];

    # Переменные окружения контейнера
    environment = {
      POSTGRES_HOST = "postgres-nextcloud:5432"; # Адрес PostgreSQL
      POSTGRES_DB = "nextcloud";
      POSTGRES_USER = "nextcloud";
      POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-nextcloud-password";

      NEXTCLOUD_ADMIN_USER = "admin";
      NEXTCLOUD_ADMIN_PASSWORD_FILE = "/run/secrets/nextcloud-admin-password";

      NEXTCLOUD_DATA_DIR = "/srv/nextcloud/data";
      NEXTCLOUD_TRUSTED_DOMAINS = "${domain} ${lanAddress} localhost";

      TRUSTED_PROXIES = "127.0.0.1 ::1 172.16.0.0/12";
      OVERWRITEHOST = domain;
      OVERWRITEPROTOCOL = "https";
      OVERWRITECLIURL = "https://${domain}";

      REDIS_HOST = "redis-nextcloud";
      REDIS_HOST_PORT = "6379";

      PHP_MEMORY_LIMIT = "1024M";
      PHP_UPLOAD_LIMIT = "20G";
      PHP_OPCACHE_MEMORY_CONSUMPTION = "256";
    };

    extraOptions = [
      "--network=server-net"
      "--network-alias=nextcloud" # Имя контейнера в docker сети
    ];
  };

  # Необходимые systemd сервисы для контейнеров

  systemd.services.${clamavService} = {
    after = [ "init-server-net.service" ];
    requires = [ "init-server-net.service" ];
  };

  systemd.services.${nextcloudService} = {
    after = [
      "init-server-net.service"
      "init-server-secrets.service"
      "prepare-nextcloud-config.service"
      postgresUnit
      redisUnit
      clamavUnit
    ];

    requires = [
      "init-server-net.service"
      "init-server-secrets.service"
      "prepare-nextcloud-config.service"
      postgresUnit
      redisUnit
      clamavUnit
    ];
  };

  systemd.services.nextcloud-cron = {
    description = "Запуск cron.php для nextcloud";

    after = [ nextcloudUnit ];
    requires = [ nextcloudUnit ];

    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${dockerBin} exec -u www-data nextcloud php /var/www/html/occ status -e";
      ExecStart = "${dockerBin} exec -u www-data nextcloud php /var/www/html/cron.php";
      KillMode = "process";
    };
  };

  systemd.timers.nextcloud-cron = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Unit = "nextcloud-cron.service";
    };
  };
}
