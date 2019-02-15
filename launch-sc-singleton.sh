#!/bin/bash
DEFAULT_SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-4.5.1-osx
DEFAULT_SC_VER=4.5.1
SC_VER=''
SC_PATH=''
LOG_PATH=/tmp/singleton-tunnel.log

setVersion () {
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

setVersion $1

echo "Launching Sauce Connect ${SC_VER}"
echo Logging to $LOG_PATH
$SC_PATH/bin/sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY -v -d /tmp/singleton-tunnel.pid -l $LOG_PATH | 
while IFS= read -r line
do
    case $line in
    *"Sauce Connect is up, you may start your tests."* )
        # SC finished successfully starting, let's stop it
        echo $'\xE2\x9C\x94'  "Sauce Connect started normally"
        echo "Stopping  the tunnel"
        SC_PID=$(cat /tmp/singleton-tunnel.pid)
        kill -INT $SC_PID
        break
        ;;
    *"Goodbye."* )
        # SC didn't start for some reason
        echo "Sauce Connect did not start"
        break
        ;;
    esac
done
