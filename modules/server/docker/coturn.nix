{config, pkgs, ...}:
let
  coturnImage = "coturn/coturn:4.12.0-alpine";

  domain = "swomp.ru";
  publicAddress = "80.251.125.180";
  privateAddress = "192.168.1.244";

  secretsDir = "/srv/secrets";

  coturnDir = "/srv/coturn";
  configDir = "${coturnDir}/config";

  backend = config.virtualisation.oci-containers.backend;
  coturnService = "${backend}-coturn";

  baseConfig = pkgs.writeText "turnserver.conf" ''
    listening-port=3478
    tls-listening-port=5349

    listening-ip=${privateAddress}
    relay-ip=${privateAddress}
    external-ip=${publicAddress}/${privateAddress}

    min-port=10000
    max-port=10100

    use-auth-secret
    realm=${domain}
    server-name=${domain}

    fingerprint
    lt-cred-mech
    no-multicast-peers
    no-cli

    cert=/certs/fullchain.pem
    pkey=/certs/key.pem

    log-file=stdout
    simple-log

    total-quota=100
    stale-nonce=600
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${coturnDir} 0755 root root -"
    "d ${configDir} 0750 root root -"
  ];

  systemd.services.prepare-coturn-config = {
    description = "Подготовка конфига coturn";

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
      install -d -m 0750 -o root -g root ${configDir}

      cat ${baseConfig} > ${configDir}/turnserver.conf
      printf "static-auth-secret=%s\n" "$(cat ${secretsDir}/coturn-static-auth-secret)" >> ${configDir}/turnserver.conf

      chmod 0640 ${configDir}/turnserver.conf
      chown root:root ${configDir}/turnserver.conf
    '';
  };

  virtualisation.oci-containers.containers.coturn = {
    image = coturnImage;
    autoStart = true;

    volumes = [
      "${configDir}/turnserver.conf:/etc/coturn/turnserver.conf:ro"
      "/var/lib/acme/${domain}/fullchain.pem:/certs/fullchain.pem:ro"
      "/var/lib/acme/${domain}/key.pem:/certs/key.pem:ro"
    ];

    extraOptions = [
      "--network=host"
    ];
  };

  systemd.services.${coturnService} = {
    after = [
      "network-online.target"
      "prepare-coturn-config.service"
      "acme-${domain}.service"
    ];

    wants = [
      "network-online.target"
    ];

    requires = [
      "prepare-coturn-config.service"
      "acme-${domain}.service"
    ];
  };
}
