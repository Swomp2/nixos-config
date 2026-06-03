{config, pkgs, ...}:
let
  synapseImage = "matrixdotorg/synapse:v1.153.0";

  serverName = "swomp.ru"; # Имя matrix сервера. Ники будут типа @something:swomp.ru
  publicBaseUrl = "https://matrix.swomp.ru/";

  secretsDir = "/srv/secrets";

  synapseDir = "/srv/synapse";
  dataDir = "${synapseDir}/data";

  backend = config.virtualisation.oci-containers.backend;
  dockerBin = "${config.virtualisation.docker.package}/bin/docker";

  synapseService = "${backend}-synapse";
  postgresUnit = "${backend}-postgres-synapse.service";
  redisUnit = "${backend}-redis-synapse.service";
in
{
  systemd.tmpfiles.rules = [
    "d ${synapseDir} 0750 991 991 -"
    "d ${dataDir} 0750 991 991 -"
    "Z ${synapseDir} - 991 991 -"
    "Z ${dataDir} - 991 991 -"
  ];

  systemd.services.prepare-synapse-config = {
    description = "Подготовка конфига synapse";

    wantedBy = [ "multi-user.target" ];

    after = [
      "init-server-secrets.service"
      "init-server-net.service"
    ];

    requires = [
      "init-server-secrets.service"
      "init-server-net.service"
    ];

    path = [
      pkgs.coreutils
      config.virtualisation.docker.package
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # Скрипт сначала создаёт signing key
    # Потом читает уже существующие секреты
    # Затем через cat создаётся конфиг synapse 
    script = ''
      install -d -m 0750 -o 991 -g 991 ${dataDir}

      if [ ! -f ${dataDir}/${serverName}.signing.key ]; then
        ${dockerBin} run --rm \
          -e SYNAPSE_SERVER_NAME=${serverName} \
          -e SYNAPSE_REPORT_STATS=no \
          -v ${dataDir}:/data \
          ${synapseImage} generate
      fi

      postgres_password="$(cat ${secretsDir}/postgres-synapse-password)"
      registration_shared_secret="$(cat ${secretsDir}/synapse-registration-shared-secret)"
      macaroon_secret_key="$(cat ${secretsDir}/synapse-macaroon-secret-key)"
      form_secret="$(cat ${secretsDir}/synapse-form-secret)"
      turn_shared_secret="$(cat ${secretsDir}/coturn-static-auth-secret)"

      cat > ${dataDir}/homeserver.yaml <<EOF
server_name: "${serverName}"
public_baseurl: "${publicBaseUrl}"

pid_file: /data/homeserver.pid
signing_key_path: /data/${serverName}.signing.key
log_config: /data/log.config
media_store_path: /data/media_store
uploads_path: /data/uploads

report_stats: false

listeners:
  - port: 8008
    tls: false
    type: http
    bind_addresses:
      - "0.0.0.0"
    x_forwarded: true
    resources:
      - names:
          - client
          - federation
        compress: false

database:
  name: psycopg2
  args:
    user: synapse
    password: "$postgres_password"
    database: synapse
    host: postgres-synapse
    port: 5432
    cp_min: 5
    cp_max: 10

redis:
  enabled: true
  host: redis-synapse
  port: 6379

enable_registration: false
enable_registration_without_verification: false
registration_shared_secret: "$registration_shared_secret"

macaroon_secret_key: "$macaroon_secret_key"
form_secret: "$form_secret"

max_upload_size: 50M
dynamic_thumbnails: true
url_preview_enabled: true
url_preview_ip_range_blacklist:
  - "127.0.0.0/8"
  - "10.0.0.0/8"
  - "172.16.0.0/12"
  - "192.168.0.0/16"
  - "169.254.0.0/16"
  - "::1/128"
  - "fe80::/10"
  - "fe00::/7"

turn_uris:
  - "turn:swomp.ru:3478?transport=udp"
  - "turn:swomp.ru:3478?transport=tcp"
  - "turns:swomp.ru:5349?transport=tcp"
turn_shared_secret: "$turn_shared_secret"
turn_user_lifetime: 1h
turn_allow_guests: true

trusted_key_servers:
  - server_name: matrix.org

presence:
  enabled: true

password_config:
  enabled: true

suppress_key_server_warning: true
EOF

      cat > ${dataDir}/log.config <<'EOF'
version: 1

formatters:
  precise:
    format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(message)s'

handlers:
  file:
    class: logging.handlers.TimedRotatingFileHandler
    formatter: precise
    filename: /data/homeserver.log
    when: midnight
    backupCount: 7
    encoding: utf8

  console:
    class: logging.StreamHandler
    formatter: precise

loggers:
  synapse:
    level: INFO

  twisted:
    level: INFO

root:
  level: INFO
  handlers:
    - file
    - console

disable_existing_loggers: false
EOF

      chown 991:991 ${dataDir}/homeserver.yaml
      chmod 0640 ${dataDir}/homeserver.yaml

      chown 991:991 ${dataDir}/log.config
      chmod 0640 ${dataDir}/log.config
      
      chown -R 991:991 ${dataDir}
    '';
  };

  virtualisation.oci-containers.containers.synapse = {
    image = synapseImage;
    autoStart = true;

    ports = [
      "127.0.0.1:8008:8008"
    ];

    volumes = [
      "${dataDir}:/data"
    ];

    extraOptions = [
      "--network=server-net"
      "--network-alias=synapse"
    ];
  };

  systemd.services.${synapseService} = {
    after = [
      "prepare-synapse-config.service"
      postgresUnit
      redisUnit
    ];

    requires = [
      "prepare-synapse-config.service"
      postgresUnit
      redisUnit
    ];
  };
}
