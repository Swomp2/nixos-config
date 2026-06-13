{osConfig, ...}:
{
  services.flatpak = {
  	enable = true;

  	remotes = [
  	  {
  	  	name     = "flathub";
  	  	location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  	  }
  	];

  	packages = [
  	  "com.logseq.Logseq"
  	  "org.telegram.desktop"
  	];

  	update.auto = {
  	  enable = true;
  	  onCalendar = "weekly";
  	};

  	overrides = {
  	  global = {
  	  	Environment = {
  	  	  TZ = osConfig.time.timeZone;

  	  	  XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

  	  	  XCURSOR_THEME = "BreezeX-RosePine-Linux";
  	  	  XCURSOR_SIZE = "32";
  	  	};

  	  	Context.filesystems = [
  	  	  "/nix/store:ro"
  	  	  "xdg-data/icons:ro"
  	  	  "~/.icons:ro"
  	  	];
  	  };
  	};
  };
}
