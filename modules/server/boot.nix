{ pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;
    
    initrd.verbose = false;
    initrd.systemd.enable = true;
    initrd.kernelModules = ["i915"];
    
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
