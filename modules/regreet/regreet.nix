{lib, config, pkgs, ...}:
{
  # Включение менеджера сеансов
  programs.regreet.enable = true;

  services.greetd = {
  	enable = true;

  	settings = {
  		default_session = lib.mkForce {
  			user = "greeter";

  			command = lib.concatStringsSep " " [
  				"${pkgs.dbus}/bin/dbus-run-session"
  				"${config.programs.hyprland.package}/bin/Hyprland"
  				"-c"
  				"/etc/greetd/hyprland.conf"
  			];
  		};
  	};
  };

  # Его конфигурация
  environment.etc."greetd/regreet.toml" = lib.mkForce {
    text = ''
      [GTK]
      application_prefer_dark_theme = true
      theme_name = "Gruvbox-Dark"
      icon_theme_name = "Papirus-Dark"
      font_name = "Ubuntu 15"

      [appearance]
      greeting_msg = "О, здарова"

      [background]
      path = "${../../home/config/greeter/wallhaven-m9mevm.jpg}"
      fit = "Cover"
    '';
  };
}
