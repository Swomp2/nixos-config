{...}:
{
  wayland.windowManager.hyprland = {
    windowrulev2 = [
      "float, title:^(Громкость)$"
      "float, title:^(Копирование файлов)$"
      "float, title:^(Подтвердить замену файлов)$"
      "float, title:^(Настройки)$"
      "float, title:^(Настройки — Strawberry Music Player)$"
      "float, title:^(Эквалайзер — Strawberry Music Player)$"
      "float, title:^(Менеджер обложек — Strawberry Music Player)$"
      "float, title:^(Библиотека)$"

      "float, class:^(lxqt-policykit-agent)$"
      "workspace 2, class:^(org.strawberrymusicplayer.strawberry)$"
      "float, class:^(org.kde.ark)$"
    ];
  };
}