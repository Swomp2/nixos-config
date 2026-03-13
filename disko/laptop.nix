{ ... }:

{
  disko.devices = {
    disk.system = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-eui.002538a341b9084d";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "600M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "umask=0077" ];
            };
          };

          boot = {
            name = "boot";
            size = "1G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };

          swap = {
            name = "swap";
            size = "16G";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 10;
            };
          };

          luks = {
            name = "cryptroot";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
