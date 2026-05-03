{pkgs, ...}:
{

  # Микрокод для процессора и другие firmware
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.fwupd.enable = true;
  services.fstrim.enable = true;

  # Это для поддержки tpm2 для автоматической расшифровки диска
  boot.initrd.systemd.tpm2.enable = true;

  # Это для мониторинга состояния дисков
  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };

  # Включение поддержки видеокарт
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
