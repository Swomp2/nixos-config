{...}:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        "match:title ^(Громкость)$, float on"
        "match:title ^(Копирование файлов)$, float on"
        "match:title ^(Подтвердить замену файлов)$, float on"
        "match:title ^(Настройки)$, float on"
        "match:title ^(Настройки — Strawberry Music Player)$, float on"
        "match:title ^(Эквалайзер — Strawberry Music Player)$, float on"
        "match:title ^(Менеджер обложек — Strawberry Music Player)$, float on"
        "match:title ^(Библиотека)$, float on"

        "match:class ^(lxqt-policykit-agent)$, float on"
        "match:class ^(org.strawberrymusicplayer.strawberry)$, workspace 2"
        "match:class ^(org.kde.ark)$, float on"
        "match:class ^(xdg-desktop-portal-gtk)$, float on"
      ];
    };
  };
}