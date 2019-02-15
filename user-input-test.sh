#!/bin/bash
DEFAULT_SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-4.5.1-osx
DEFAULT_SC_VER=4.5.1
USER_SC_VER=''
USER_SC_PATH=''

setPath () {
    if [ -z $1 ]
    then
        echo Using sauce connect ${DEFAULT_SC_VER} at ${DEFAULT_SC_PATH}
    else
        USER_SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-$1-osx
        USER_SC_VER=$1
        echo 'Using sauce connect' $1 'at' $USER_SC_PATH
    fi
}

setPath $1
