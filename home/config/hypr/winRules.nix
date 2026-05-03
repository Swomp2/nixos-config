{...}:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        "title:^(Громкость)$, float on"
        "title:^(Копирование файлов)$, float on"
        "title:^(Подтвердить замену файлов)$, float on"
        "title:^(Настройки)$, float on"
        "title:^(Настройки — Strawberry Music Player)$, float on"
        "title:^(Эквалайзер — Strawberry Music Player)$, float on"
        "title:^(Менеджер обложек — Strawberry Music Player)$, float on"
        "title:^(Библиотека)$, float on"

        "class:^(lxqt-policykit-agent)$, float on"
        "class:^(org.strawberrymusicplayer.strawberry)$, workspace 2"
        "class:^(org.kde.ark)$ float on"
      ];
    };
  };
}