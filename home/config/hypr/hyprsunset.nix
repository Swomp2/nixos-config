{pkgs, unstable, ...}:
{
  services.hyprsunset = {
    enable = true;
    package = unstable.hyprsunset;

    settings = {
      profile = [
        {
          time = "6:00";
          identity = true;
        }

        {
          time = "21:00";
          temperature = 5500;
        }
      ];
    };
  };
}