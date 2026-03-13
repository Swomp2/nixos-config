{ pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    initrd.kernelModules = ["amdgpu"];
    
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    plymouth = {
      enable = true;

      # Для первого теста лучше взять тему, которая точно умеет графический ввод пароля
      theme = "bgrt";

      # Необязательно, но можно задать
      # logo = ./assets/plymouth-logo.png;
      # font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";
    };
  };
}
