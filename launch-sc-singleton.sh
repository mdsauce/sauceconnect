#!/bin/bash
DEFAULT_SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-4.5.1-osx
DEFAULT_SC_VER=4.5.1
SC_VER=''
SC_PATH=''

setPath () {
    if [ -z $1 ]
    then
        echo Using sauce connect ${DEFAULT_SC_VER} at ${DEFAULT_SC_PATH}
        SC_PATH=$DEFAULT_SC_PATH
        SC_VER=$DEFAULT_SC_VER
    else
        SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-$1-osx
        SC_VER=$1
        echo 'Using sauce connect' $1 'at' $SC_PATH
    fi
}

setPath $1

echo "Launching Sauce Connect ${SC_VER}"
$SC_PATH/bin/sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY -v -d /tmp/singleton-tunnel.pid | 
while IFS= read -r line
do
    case $line in
    *"Sauce Connect is up, you may start your tests."* )
        # SC finished successfully starting, let's stop it
        echo "Sauce Connect started normally"
        echo "Stopping"
        SC_PID=$(cat /tmp/singleton-tunnel.pid)
        echo $SC_PID
        kill -INT $SC_PID
        break
        ;;
    esac
done
