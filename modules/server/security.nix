{config, pkgs, lib, username, ...}:
{
  boot.lanzaboote = {
  	enable = true;
  	pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [
  	pkgs.sbctl
  ];

  users.users.${username} = {
  	openssh.authorizedKeys.keyFiles = [
  	  ./keys/pc.pub
  	  ./keys/laptop.pub
  	];
  };

  services.openssh = {
  	enable = true;
  	openFirewall = false;

  	hostKeys = [
  	  {
  	    path = "/etc/ssh/ssh_host_ed25519_key";
  	    type = "ed25519";
  	  }
  	];

  	settings = {
  	  PermitRootLogin              = "no";
  	  PasswordAuthentication       = false;
  	  KbdInteractiveAuthentication = false;
  	  PubkeyAuthentication         = true;

  	  AllowUsers = [
  	  	username
  	  ];

  	  X11Forwarding        = false;
  	  AllowAgentForwarding = "no";
  	  PermitTunnel         = "no";
  	  UseDNS               = false;
  	};
  };

  # Настройки sudo
  security.sudo = {
  	enable = true;
  	wheelNeedsPassword = true;
  };

  # Настройки файервола
  networking.firewall = {
  	enable = true;
  	
  	checkReversePath = false;
  	logReversePathDrops = false;

	# Разрешённые входящие TCP для игр, звонков, TURN
  	allowedTCPPorts = [
  	  22   # SSH
  	  53   # Pi-hole DNS TCP
  	  80   # HTTP для Let's Encrypt и redirect
  	  443  # HTTPS nginx
  	  3478 # coturn TCP
  	  5349 # coturn TLS TCP
  	];

	# Разрешённые UDP для игр, звонков, TURN/WebRTC
  	allowedUDPPorts = [
  	  53   # Pi-hole DNS UDP
  	  3478 # coturn UDP
  	  5349 # coturn TLS UDP
  	];

  	# Главный диапазон для TURN relay
  	allowedUDPPortRanges = [
  	  {
  	    from = 10000; 
  	    to = 10100;
  	  }
  	];

  	# ping для проверки работы сервера
  	allowPing = true;
  };

  # Защита от перебора пароля от SSH
  services.fail2ban = {
  	enable   = true;

  	maxretry = 2;
  	bantime  = "2h";

  	ignoreIP = [
  	  "127.0.0.0/8"
  	  "::1"
  	  "192.168.1.0/24"
  	];
  };

  # Ужесточение ядра для сети
  boot.kernel.sysctl = {
    # Не принимать ICMP редиректы
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # Не принимать source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # Логировать martian packets(пакеты с невозможными или подозрительными адресами)
    "net.ipv4.conf.all.log_martians" = 1;

    # Защита от SYN flood
    "net.ipv4.tcp_syncookies" = 1;

    # Ограничить ptrace(механизм, с помощью которого один процесс может наблюдать за другим)
    "kernel.yama.ptrace_scope" = 1;
  };
}
