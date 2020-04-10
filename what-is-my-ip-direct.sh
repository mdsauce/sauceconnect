#!/bin/bash
SC_PATH=/Users/maxdobeck/workspace/scstuff/sc-4.5.4-osx
SC_VER=4.5.4
LOG_PATH=/tmp/what-is-my-ip-direct.log
NAME=ip-address-direct

echo "Launching Sauce Connect ${SC_VER}"
echo Logging to $LOG_PATH

if [ "$1" == "rdc"  ]; then
$SC_PATH/bin/sc -u $RDC_ADMIN_USERNAME -k $RDC_SC_API_KEY -v -i $NAME -d /tmp/singleton-tunnel.pid -l $LOG_PATH --direct-domains duckduckgo.com,whatismyipaddress.com -x https://us1.api.testobject.com/sc/rest/v1 -B all
  else
$SC_PATH/bin/sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY -v -i $NAME -d /tmp/singleton-tunnel.pid -l $LOG_PATH --direct-domains duckduckgo.com,whatismyipaddress.com -B all
fi

