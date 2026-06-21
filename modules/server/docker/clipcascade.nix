{ config, ... }:
let
  clipcascadeImage = "sathvikrao/clipcascade:0.7.0";

  clipcascadeDir = "/srv/clipcascade";
  databaseDir = "${clipcascadeDir}/database";

  backend = config.virtualisation.oci-containers.backend;
  clipcascadeService = "${backend}-clipcascade";
in
{
  systemd.tmpfiles.rules = [
    "d ${clipcascadeDir} 0755 root root -"
    "d ${databaseDir} 0755 root root -"
  ];

  virtualisation.oci-containers.containers.clipcascade = {
    image = clipcascadeImage;
    autoStart = true;

    # Открытие порта для nginx
    ports = [
      "127.0.0.1:8090:8080"
    ];

    volumes = [
      "${databaseDir}:/database"
    ];

    environment = {
      SERVER_FORWARD_HEADERS_STRATEGY = "framework";
      CC_MAX_MESSAGE_SIZE_IN_MiB = "50"; # Максимальный размер сообщения
      CC_P2P_ENABLED = "false"; # Отключение p2p режима, чтобы ВСЕ сообщения шли через сервер
      CC_ALLOWED_ORIGINS = "https://cc.swomp.ru,null"; # Запросы разрешены только из cc.swomp.ru
      CC_SIGNUP_ENABLED = "false"; # Отключение регистрации новых пользователей
    };

    extraOptions = [
      "--network=server-net"
      "--network-alias=clipcascade"
    ];
  };

  systemd.services.${clipcascadeService} = {
    after = [
      "init-server-net.service"
    ];

    requires = [
      "init-server-net.service"
    ];
  };
}
