#Fix some putty display problems
if [ "$PS1" ]; then
  export NCURSES_NO_UTF8_ACS=1
fi