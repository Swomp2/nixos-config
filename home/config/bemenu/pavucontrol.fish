#!/bin/fish

if pgrep -x pavucontrol-qt
   pkill pavucontrol-qt
else
   exec pavucontrol-qt
end