#!/bin/bash -u

function machine_is
{
  OS=`uname -v`
  [[ ! "${OS//$1/}" == "$OS" ]] && return 0 || return 1
}

function ensure_dependencies
{
  #install dependencies
  for i in $@
  do
    if machine_is Ubuntu
    then
      if [ -z "`dpkg -s $i 2> /dev/null`" ]
      then
        echo "Need to install $i"
        sudo apt-get install $i 1>&2 || return 3
      fi
    fi
    if machine_is Darwin
    then
      #don't install things that are already provided by apple
      [ ! -z "`$i --version 2> /dev/null`" ] && continue
      if [ -z "`brew ls --versions $i`" ]
      then
        echo "Need to install $i"
        brew install $i 1>&2 || return $?
      fi
    fi
  done
}

#need imagemagick
ensure_dependencies imagemagick

#check which viewer works on this machine
if machine_is Darwin
then
  VIEWER="open -f -a Preview"
else
  VIEWER="display "
fi

#define the flags to be used
FLAGS=

#delete any pre-define geometry parameters
FLAGS+="-geometry +1+1 "
#add filenames as labels
FLAGS+="-label %d/%t $@ -pointsize 12 "

montage $FLAGS png:- | $VIEWER