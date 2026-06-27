{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    configPath = ".mozilla/firefox";

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
