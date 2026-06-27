{pkgs, ...}:

{
  programs.firefox = {
  	enable = true;
  	package = pkgs.firefox;

  	languagePacks = [
  	  "ru"
  	  "en-US"
  	];

  	policies = {
  	  RequestedLocales = [
  	  	"ru"
  	  	"en-US"
  	  ];
  	};
  };
}
