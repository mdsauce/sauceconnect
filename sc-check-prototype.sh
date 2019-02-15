#!/bin/bash

TIMESTAMP=$(date)
SC=/Users/mattdunn/dev/sc-4.4.0-osx/bin/sc
SC_USER=$SAUCE_USERNAME
SC_KEY=$SAUCE_ACCESS_KEY
LOG_DIR=/Users/mattdunn/temp/SC596logs
STDOUT_LOG=SC596stdout.log
SC_LOG=sclog.log
SC596_LOG=SC596.log
PIDFILE=/tmp/sc_client.pid
NUMOFTESTS=500

function getPid {
   PID=$(cat $PIDFILE)
}

function start {

  getPid

  if [[ -z "$PID" ]]
    then
      echo "$TIMESTAMP Running: $SC -u $SC_USER -k ***** -v -l $LOG_DIR/$SC_LOG > $LOG_DIR/$STDOUT_LOG 2>&1 &"
      $SC -u $SC_USER -k $SC_KEY -v -l $LOG_DIR/$SC_LOG > $LOG_DIR/$STDOUT_LOG 2>&1 &
      echo "$TIMESTAMP monitoring $LOG_DIR/$STDOUT_LOG"
      # monitor SC stdout logfile for certain messages
      while read line;do
        case "$line" in
            *"Sauce Connect is up, you may start your tests."* )
                # SC finished successfully starting, let's stop it
                echo "$TIMESTAMP Sauce Connect Proxy started, stopping"
                stop
                break
                ;;
           	*"Error bringing up tunnel VM."* )
            	# SC didn't start and could be a case of SC-596 - keep the logfile
                echo "$TIMESTAMP Error bringing up tunnel VM caught - SC-596 may have happened!!!!"
                cat $LOG_DIR/$SC_LOG >> $LOG_DIR/$SC596_LOG
                break
                ;;
            *"Goodbye."* )
                # SC didn't start but for some other reason
                echo "$TIMESTAMP Sauce Connect Proxy did not start"
                break
                ;;
        esac
      done < <(tail -f $LOG_DIR/$STDOUT_LOG)
    else
      echo "$TIMESTAMP Sauce Connect Proxy already running, stopping"
      stop
  fi

  # kill the leftover tail process
  pkill -9 tail
}

function stop {
  # stop SC if running

  getPid

  if [ -z "$PID" ]
    then
     echo "$TIMESTAMP Sauce connect Proxy was not running"
    else
      echo "$TIMESTAMP Halting process id $PID"
      kill -2 $PID
      # monitor SC logfile and wait for it to finish shutting down
      while read line;do
          case "$line" in
              *"Goodbye"* )
                  echo "Sauce Connect started normally"
                  kill -l
                  break
                  ;;
          esac
      done < <(tail -f $LOG_DIR/$STDOUT_LOG)
      rm -f $PIDFILE
  fi

  # kill the leftover tail process
  pkill -9 tail
}

# start SC $NUMOFTESTS times
echo "$TIMESTAMP will start Sauce Connect Proxy $NUMOFTESTS times"
for ((i=1; i<=$NUMOFTESTS; i++)); do
    rm -f $LOG_DIR/$SC_LOG
    rm -f $LOG_DIR/$STDOUT_LOG
    echo "$TIMESTAMP Sauce Connect Proxy start #$i"
    start
done

