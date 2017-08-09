#!/usr/bin/bash

WTITLE=$(xdotool getwindowfocus -f getwindowname)

echo $WTITLE >> /home/luke/i3kill.log

[[ "$WTITLE" == Baystation\ 12\ -\ * ]] && {
  echo "No kill" >> /home/luke/i3kill.log
  exit 0
}


echo "Kill" >> /home/luke/i3kill.log
i3-msg kill
