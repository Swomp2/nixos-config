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
        owner="$2"
        mode="$3"
      
        if [ ! -s "$file" ]; then
          openssl rand -base64 48 > "$file"
        fi
      
        chown "$owner" "$file"
        chmod "$mode" "$file"
      }

      generate_secret /srv/secrets/postgres-nextcloud-password 82:82 0400
      generate_secret /srv/secrets/postgres-synapse-password 82:82 0400
      
      generate_secret /srv/secrets/nextcloud-admin-password root:root 0400
      
      generate_secret /srv/secrets/pihole-web-password root:root 0400
      
      generate_secret /srv/secrets/coturn-static-auth-secret root:root 0400
      
      generate_secret /srv/secrets/synapse-registration-shared-secret root:root 0400
      generate_secret /srv/secrets/synapse-macaroon-secret-key root:root 0400
      generate_secret /srv/secrets/synapse-form-secret root:root 0400
    '';
  };
}
