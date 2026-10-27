# Common functions for usizo devices -*- shell-script -*-

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/firmware/usizo.cfg ] && . /boot/firmware/usizo.cfg

usizolog() {
    local me=$(basename $0)
    logger -t usizo -- "$* [${me}]" || printf '%s\n' "usizo: $* [${me}]" >&2
}

usizofatal() {
    usizolog "FATAL: $*"
    exit 1
}

usziotelemetry() (
    usizolog "$*"
    query_count=$#
    while [ "${query_count}" -gt 0 ]; do
        query=$1
        shift
        case "${query}" in
            POST:*) set -- "$@" --data-urlencode "${query#POST:}" ;;
            *) set -- "$@" --url-query "$query" ;;
        esac
        query_count=$((query_count - 1))
    done

    local _usizo=$(cat /sys/class/net/eth0/address)
    local _ts=$(date +%s)
    local _uptime=$(cat /proc/uptime | awk '{print $1}')

    curl -m 5 -sD /dev/null -o /dev/null "${CALLBACK_URL}" \
        --url-query "usizo=${_usizo}" \
        --url-query "ts=${_ts}" \
        --url-query "uptime=${_uptime:=0}" \
        "$@"
)
