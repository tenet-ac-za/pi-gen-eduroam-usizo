#!/bin/sh

. /usr/local/lib/usizo-functions

RESPONSE_HEADERS=$(curl -m 5 -sD - -o /dev/null "${CALLBACK_URL}" \
        --url-query "usizo=$(cat /sys/class/net/eth0/address)" \
        --url-query "datetime=1")
if [ $? -ne 0 -o -z "$RESPONSE_HEADERS" ] ; then
    usizofatal "did not get a response from ${CALLBACK_URL}"
fi

HTTP_DATE=$(printf '%s\n' "${RESPONSE_HEADERS}" | awk '
    tolower($1) == "date:" {
        sub(/^[^:]*:[[:space:]]*/, "")
        sub(/\r$/, "")
        value = $0
    }
    END { print value }
')

if [ -z "${HTTP_DATE}" ]; then
    usizofatal "response from ${CALLBACK_URL} did not include a Date header"
fi

if ! TIMESTAMP=$(date -u -d "${HTTP_DATE}" '+%s' 2>/dev/null) ||
    [ -z "${TIMESTAMP}" ]; then
    usizofatal "invalid Date header from ${CALLBACK_URL}: ${HTTP_DATE}"
fi

if date -u -s "@${TIMESTAMP}" >/dev/null; then
    usizolog "Set system time from ${CALLBACK_URL} to ${HTTP_DATE} UTC"
else
    usizofatal "unable to set system time from ${CALLBACK_URL}"
fi
