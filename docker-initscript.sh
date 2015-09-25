#!/bin/bash
DEBUG=${DEBUG:-}
DEBUG_FLAG=""
if [ ! -z $DEBUG ]
then
    set -x
    DEBUG_FLAG="-debug=true"
fi
PROXIES=${PARENT_PROXIES:-}
ALWAYS_PROXY=${ALWAYS_PROXY:-false}
LOAD_BALANCE=${LOAD_BALANCE:-backup}
ALLOWED_CLIENT=${ALLOWED_CLIENT:-}
USER_PASSWORD=${USER_PASSWORD:-}
USER_PASSWORD_FILE=${USER_PASSWORD_FILE:-}
AUTH_TIMEOUT=${AUTH_TIMEOUT:=2h}
HTTP_ERROR_CODE=${HTTP_ERROR_CODE:-}
CORE_COUNT=${CORE_COUNT:-1}
ESTIMATE_TARGET=${ESTIMATE_TARGET:-example.com}
TUNNEL_ALLOWED_PORT=${TUNNEL_ALLOWED_PORT:-}
DIAL_TIMEOUT=${DIAL_TIMEOUT:-}
READ_TIMEOUT=${READ_TIMEOUT:-}
DETECT_SSL_ERROR=${DETECT_SSL_ERROR:-false}

CONFIG_FILE="/config.rc"

if [ "$1" == "cow" ]
then
   cat > $CONFIG_FILE  <<EOF
listen = 0.0.0.0:7777
logFile =/data/log
alwaysProxy = ${ALWAYS_PROXY}
loadBalance = ${LOAD_BALANCE}
detectSSLErr = ${DETECT_SSL_ERROR}
estimateTarget = ${ESTIMATE_TARGET}
core = ${CORE_COUNT}
authTimeout = ${AUTH_TIMEOUT}
EOF

   if [ -f /data/$USER_PASSWORD_FILE ]
   then
       cat >> $CONFIG_FILE <<EOF
userPasswd = /data/${USER_PASSWORD}
EOF
   else
       if [ ! -z ${USER_PASSWORD} ]
       then
           echo "userPasswd = ${USER_PASSWORD}" >> $CONFIG_FILE
       fi
   fi

   if [ ! -z ${ALLOWED_CLIENT} ]
   then
      echo "allowedClient = ${ALLOWED_CLIENT}" >> $CONFIG_FILE
   fi

   if [ ! -z ${HTTP_ERROR_CODE} ]
   then
      echo "httpErrorCode = ${HTTP_ERROR_CODE}" >> $CONFIG_FILE
   fi

   if [ ! -z ${DIAL_TIMEOUT} ]
   then
      echo "dialTimeout = ${DIAL_TIMEOUT}" >> $CONFIG_FILE
   fi

   if [ ! -z ${READ_TIMEOUT} ]
   then
      echo "readTimeout = ${READ_TIMEOUT}" >> $CONFIG_FILE
   fi

   IFS=',' read -a proxies <<< "$PROXIES"

   for proxy in "${proxies[@]}"
   do
       echo "Proxy = $proxy" >> $CONFIG_FILE
   done

   [ -f /data/blokced ] || touch /data/blocked
   [ -f /data/direct ] || touch /data/direct
   [ -f /data/stat ] || touch /data/stat

   cat >> $CONFIG_FILE  <<EOF
statFile = /data/stat
blockedFile = /data/blocked
directFile = /data/direct
EOF

   /cow -rc=$CONFIG_FILE ${DEBUG_FLAG}
else
    exec "$@"
fi
