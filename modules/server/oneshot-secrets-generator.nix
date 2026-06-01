{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /srv/secrets 0700 root root -"
  ];

  systemd.services.init-server-secrets = {
    description = "Generate server secrets";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    path = [
      pkgs.openssl
      pkgs.coreutils
    ];

    script = ''
      set -eu

      install -d -m 700 -o root -g root /srv/secrets

      generate_secret() {
        file="$1"

        if [ ! -f "$file" ]; then
          openssl rand -base64 48 > "$file"
          chmod 600 "$file"
          chown root:root "$file"
        fi
      }

      generate_secret /srv/secrets/postgres-nextcloud-password
      generate_secret /srv/secrets/postgres-synapse-password
      generate_secret /srv/secrets/coturn-static-auth-secret
      generate_secret /srv/secrets/synapse-registration-shared-secret
      generate_secret /srv/secrets/nextcloud-admin-password
    '';
  };
}
