{ pkgs, username, ... }:

{
  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  users.users.${username}.extraGroups = [
    "libvirtd"
  ];

  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
