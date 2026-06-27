{ pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    postgres-nextcloud = {
      image = "postgres:18.4-alpine";
      autoStart = true;

      volumes = [
        "/srv/postgres/nextcloud:/var/lib/postgresql/data"
        "/srv/secrets/postgres-nextcloud-password:/run/secrets/postgres-nextcloud-password:ro"
      ];

      environment = {
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-nextcloud-password";
      };

      extraOptions = [
        "--network=server-net"
        "--network-alias=postgres-nextcloud"
      ];
    };

    postgres-synapse = {
      image = "postgres:16-alpine";
      autoStart = true;

      volumes = [
        "/srv/postgres/synapse:/var/lib/postgresql/data"
        "/srv/secrets/postgres-synapse-password:/run/secrets/postgres-synapse-password:ro"
      ];

      environment = {
        POSTGRES_DB = "synapse";
        POSTGRES_USER = "synapse";
        POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-synapse-password";

        # Стандартная локаль для synapse
        POSTGRES_INITDB_ARGS = "--encoding=UTF8 --locale=C";
      };

      extraOptions = [
        "--network=server-net"
        "--network-alias=postgres-synapse"
      ];
    };
  };

  systemd.services.prepare-postgres-storage = {
    description = "Подготовка директорий для PostgreSQL";
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.coreutils
      pkgs.e2fsprogs
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      mkdir -p /srv/postgres/nextcloud /srv/postgres/synapse

      ${pkgs.e2fsprogs}/bin/chattr +C /srv/postgres || true
      ${pkgs.e2fsprogs}/bin/chattr +C /srv/postgres/nextcloud || true
      ${pkgs.e2fsprogs}/bin/chattr +C /srv/postgres/synapse || true
    '';
  };

  systemd.services.docker-postgres-nextcloud = {
    after = [
      "init-server-net.service"
      "prepare-postgres-storage.service"
      "init-server-secrets.service"
    ];

    requires = [
      "init-server-net.service"
      "prepare-postgres-storage.service"
      "init-server-secrets.service"
    ];
  };

  systemd.services.docker-postgres-synapse = {
    after = [
      "init-server-net.service"
      "prepare-postgres-storage.service"
      "init-server-secrets.service"
    ];

    requires = [
      "init-server-net.service"
      "prepare-postgres-storage.service"
      "init-server-secrets.service"
    ];
  };
}
