{ config, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  collaboraService = "${backend}-collabora";
in
{
  virtualisation.oci-containers.containers.collabora = {
    image = "collabora/code:26.04.1.4.1";
    autoStart = true;

    ports = [
      "127.0.0.1:9980:9980"
    ];

    environment = {
      aliasgroup1 = "https://cloud.swomp.ru:443";
      
      server_name = "office.swomp.ru";
      
      extra_params = builtins.concatStringsSep " " [
        "--o:ssl.enable=false"
        "--o:ssl.termination=true"
        "--o:welcome.enable=false"
      
        "--o:net.post_allow.host[0]=cloud\\.swomp\\.ru"
        "--o:net.post_allow.host[1]=office\\.swomp\\.ru"
      
        "--o:storage.wopi.host[0]=cloud\\.swomp\\.ru"
        "--o:storage.wopi.host[1]=office\\.swomp\\.ru"
      ];
      
      dictionaries = "ru_RU en_US";
    };

    extraOptions = [
      "--network=server-net"
      "--network-alias=collabora"
      "--cap-add=MKNOD"
    ];
  };

  systemd.services.${collaboraService} = {
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "docker.service"
      "init-server-net.service"
    ];
    requires = [
      "docker.service"
      "init-server-net.service"
    ];
  };
}
