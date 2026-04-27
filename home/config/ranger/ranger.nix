{ pkgs, ... }:

{
  programs.ranger = {
    enable = true;
    
    settings = {
      preview_files = true;
      preview_directories = true;
      use_preview_script = true;

      preview_images = true;
      preview_images_method = "kitty";
    };

    extraPackages = with pkgs; [
      file
      ffmpegthumbnailer
      poppler-utils
      highlight
      atool
      mediainfo
      w3m
    ];
  };
}
