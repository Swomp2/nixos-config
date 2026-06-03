{config, ...}:
let
  nextcloudRoot = "/srv/nextcloud/html";
  uploadLimit = "20G"; # Максимальный размер загрузки через nginx

  # IP HA в локальной сети
  homeAssistantHost = "192.168.1.106";
in
{
  # Настройки для Let's Encrypt
  security.acme = {
    acceptTerms = true;

    defaults.email = "swompweb@gmail.com";
  };

  # Настройки самого nginx
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      # Настройки для основного домена
      "swomp.ru" = {
        forceSSL   = true; # Включение https
        enableACME = true; # Включение подписи через Let's Encrypt

        # Служебный адрес для matrix federation
        locations."= /.well-known/matrix/server".extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin "*" always;
          return 200 '{"m.server":"matrix.swomp.ru:443"}';
        '';

        # Служебный адрес для клиентов типа element
        locations."= /.well-known/matrix/client".extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin "*" always;
          return 200 '{"m.homeserver":{"base_url":"https://matrix.swomp.ru"}}';
        '';

        # Обычного сайта на домене просто нет
        locations."/".extraConfig = ''
          return 404;
        '';
      };

      "cloud.swomp.ru" = {
        forceSSL = true;
        enableACME = true;

        root = nextcloudRoot;

        extraConfig = ''
          index index.php index.html /index.php$request_uri;

          client_max_body_size ${uploadLimit};
          fastcgi_buffers 64 4K;

          add_header Referrer-Policy "no-referrer" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Permitted-Cross-Domain-Policies "none" always;
          add_header X-Robots-Tag "noindex, nofollow" always;
          add_header X-XSS-Protection "1; mode=block" always;

          fastcgi_hide_header X-Powered-By;
        '';

        # Надо для CardDAV
        locations."= /.well-known/carddav".extraConfig = ''
          return 301 /remote.php/dav/;
        '';

       # Надо для CalDAV
        locations."= /.well-known/caldav".extraConfig = ''
          return 301 /remote.php/dav/;
        '';

        # Служебные эндпоинты nextcloud
        locations."= /.well-known/webfinger".extraConfig = ''
          return 301 /index.php/.well-known/webfinger;
        '';

        locations."= /.well-known/nodeinfo".extraConfig = ''
          return 301 /index.php/.well-known/nodeinfo;
        '';

        # Запрет доступа к внутренним директориям
        locations."~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)".extraConfig = ''
          return 404;
        '';

        # Запрет доступа к внутренним файлам
        locations."~ ^/(?:\\.|autotest|occ|issue|indie|db_|console)".extraConfig = ''
          return 404;
        '';

        # Правило для всех php запросов
        locations."~ \\.php(?:$|/)".extraConfig = ''
          fastcgi_split_path_info ^(.+?\.php)(/.*)$;
          set $path_info $fastcgi_path_info;

          try_files $fastcgi_script_name =404;

          include ${config.services.nginx.package}/conf/fastcgi_params;

          fastcgi_param DOCUMENT_ROOT /var/www/html;
          fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
          fastcgi_param PATH_INFO $path_info;
          fastcgi_param HTTPS on;
          fastcgi_param modHeadersAvailable true;
          fastcgi_param front_controller_active true;

          fastcgi_pass 127.0.0.1:9000;

          fastcgi_intercept_errors on;
          fastcgi_request_buffering off;

          fastcgi_read_timeout 3600;
          fastcgi_send_timeout 3600;
        '';

        locations."^~ /index.php".extraConfig = ''
          fastcgi_split_path_info ^(.+?\.php)(/.*)$;
          set $path_info $fastcgi_path_info;
        
          include ${config.services.nginx.package}/conf/fastcgi_params;
        
          fastcgi_param DOCUMENT_ROOT /var/www/html;
          fastcgi_param SCRIPT_FILENAME /var/www/html/index.php;
          fastcgi_param PATH_INFO $path_info;
          fastcgi_param PATH_TRANSLATED /var/www/html$path_info;
          fastcgi_param HTTPS on;
          fastcgi_param modHeadersAvailable true;
          fastcgi_param front_controller_active true;
        
          fastcgi_pass 127.0.0.1:9000;
        
          fastcgi_intercept_errors on;
          fastcgi_request_buffering off;
        
          fastcgi_read_timeout 3600;
          fastcgi_send_timeout 3600;
        '';

        # Правила для статических файлов nextcloud
        locations."~ \\.(?:css|js|mjs|svg|gif|ico|jpg|jpeg|png|webp|wasm|tflite|map|ogg|flac)$".extraConfig = ''
          try_files $uri /index.php$request_uri;

          access_log off;
          expires 6M;
        '';

        # Правила для шрифтов
        locations."~ \\.(?:otf|woff2?)$".extraConfig = ''
          try_files $uri /index.php$request_uri;
          expires 7d;
          access_log off;
        '';

        # Главный фолбэк
        # Логика такая:
        # 1. если есть файл - отдать его
        # 2. если есть директория - отдать её
        # 3. иначе передать запрос в /index.php
        locations."/".extraConfig = ''
          try_files $uri $uri/ /index.php$request_uri;
        '';
      };

      # Прокси для pihole
      "pihole.swomp.ru" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8081";
          proxyWebsockets = true;
        };
      };

      # Прокси для ClipCascade
      "cc.swomp.ru" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8090";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_read_timeout 3600;
            proxy_send_timeout 3600;
          '';
        };
      };

      # Прокси для Home Assistant
      "ha.swomp.ru" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${homeAssistantHost}:8123";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 3600;
            proxy_send_timeout 3600;
          '';
        };
      };

      # Прокси для synapse
      "matrix.swomp.ru" = {
        forceSSL = true;
        enableACME = true;

        # Ограничение размера загружаемых файлов до 50 мб
        extraConfig = ''
          client_max_body_size 50M;
        '';

        # Открывается корень - отправляется ошибка 
        locations."/".extraConfig = ''
          return 404;
        '';

        # Отправление всех API запросов в synapse
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          proxyWebsockets = true;
        };

        # Эндпоинты для клиентов synapse
        locations."/_synapse/client" = {
          proxyPass = "http://127.0.0.1:8008";
          proxyWebsockets = true;
        };
      };
    };
  };
}
