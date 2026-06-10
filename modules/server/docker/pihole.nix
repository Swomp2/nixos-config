{config, ...}:
let
  piholeImage   = "pihole/pihole:2026.05.0";

  secretsDir    = "/srv/secrets";

  piholeDir     = "/srv/pihole";
  etcPiholeDir  = "${piholeDir}/etc-pihole";
  dnsmasqDir    = "${piholeDir}/etc-dnsmasq.d";

  backend       = config.virtualisation.oci-containers.backend;

  piholeService = "${backend}-pihole";
in
{
  systemd.tmpfiles.rules = [
    "d ${piholeDir} 0755 root root -"
    "d ${etcPiholeDir} 0755 root root -"
    "d ${dnsmasqDir} 0755 root root -"
  ];

  virtualisation.oci-containers.containers.pihole = {
    image = piholeImage;
    autoStart = true;

    # Открытие портов устройствам в сети. Прокси сервер для них не нужен
    ports = [
      "192.168.1.244:53:53/tcp"
      "192.168.1.244:53:53/udp"
      "127.0.0.1:8081:80/tcp" # Доступ к веб интерфейсу только через nginx
    ];

    volumes = [
      "${etcPiholeDir}:/etc/pihole"
      "${dnsmasqDir}:/etc/dnsmasq.d"
      "${secretsDir}/pihole-web-password:/run/secrets/pihole-web-password:ro" # Пароль от веб интерфейса
    ];

    environment = {
      TZ = "Europe/Moscow";

      WEBPASSWORD_FILE = "/run/secrets/pihole-web-password";

      FTLCONF_dns_listeningMode = "all";
      FTLCONF_dns_upstreams = "1.1.1.1;9.9.9.9";

      FTLCONF_misc_etc_dnsmasq_d = "true"; # Прямое разрешение использовать кастомные файлы
    };

    extraOptions = [
      "--network=server-net"
      "--network-alias=pihole"
      "--dns=1.1.1.1"
      "--dns=9.9.9.9"
    ];
  };

  systemd.services.${piholeService} = {
    after = [
      "network-online.target"
      "docker.service"
      "init-server-net.service"
      "init-server-secrets.service"
    ];

    requires = [
      "docker.service"
      "init-server-net.service"
      "init-server-secrets.service"
    ];
  };
}
