if [ "$PS1" ]; then
  #For ROOT user only
  if [ "$EUID" = "0" ]; then
    if hash nano 2>/dev/null; then
      #Use nano instead of vi for visudo
      export EDITOR=nano
    fi
  fi
fi