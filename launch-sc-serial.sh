#!/bin/bash
DEFAULT_SC_PATH=/Users/maxdobeck/workspace/sauce_connect/sc-4.5.1-osx
DEFAULT_SC_VER=4.5.1
SC_VER=''
SC_PATH=''
LOG_PATH=/tmp/sc-five-$(date +"%Y-%m-%d_%H-%M-%S").log
PID_FILE=/tmp/sc-five-$(date +"%Y-%m-%d_%H-%M-%S").pid

# setVersion declares the version and sets it for later use by the shell
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

cleanup () {
    rm $PID_FILE
}

setVersion $1

i=0
touch /tmp/tunnel-count
# Launch X number of tunnels in serial
while [ $i -lt 2 ]
do
    i=$[$i+1]
    echo "Launching Sauce Connect ${SC_VER}"
    echo Logging to $LOG_PATH
    # SC Command line should evaluate as if you typed it in yourself
    $SC_PATH/bin/sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY -v -d $PID_FILE -l $LOG_PATH --se-port 0 | 
    while IFS= read -r line
    do
        # Read every line as it appears in the STDOUT you would normally see in your terminal
        case $line in
        *"Sauce Connect is up, you may start your tests."* )
            # SC finished successfully starting, let's stop it
            echo $'\xE2\x9C\x94'  "Sauce Connect started normally"
            echo "Stopping  the tunnel"
            SC_PID=$(cat $PID_FILE)
            cleanup
            echo "$SC_PID tunnel opened" >> /tmp/tunnel-count
            kill -INT $SC_PID
            break
            ;;
        *"Goodbye."* )
            # SC didn't start for some reason
            echo $'\xE2\x9C\x96' "Sauce Connect did not start"
            break
            ;;
        esac
    done
done
tunnels_opened=$(wc -l < /tmp/tunnel-count)
echo "${tunnels_opened}/${i} tunnels started"
rm /tmp/tunnel-count