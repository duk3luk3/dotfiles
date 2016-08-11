[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources


setxkbmap -option compose:rwin
echo -e "clear mod3\nremove mod4 = Super_L\nadd mod3 = Super_L" | xmodmap -

exec i3
