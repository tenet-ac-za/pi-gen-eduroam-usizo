#!/bin/sh
set -eu

. /usr/local/lib/usizo-functions

if [ "${USIZO_SCAN_WIFI:-}" != "1" ]; then
    exit 0
fi

cache_dir=/var/cache/usizo
cache_file=${cache_dir}/wifi.json
lock_file=/run/lock/usizo-wifi-scan.lock

mkdir -p "${cache_dir}" /run/lock || usizofatal "Unable to create Wi-Fi scan directories"
exec 9>"${lock_file}" || usizofatal "Unable to open Wi-Fi scan lock"
if ! flock -n 9; then
    usizolog "Wi-Fi scan already in progress; skipping"
    exit 0
fi

temporary_file=$(mktemp "${cache_dir}/wifi.json.XXXXXX") || usizofatal "Unable to create temporary Wi-Fi cache file"
trap 'rm -f "${temporary_file}"' EXIT HUP INT TERM

scan_results=$(wpa_cli -i wlan0 scan_results) || usizofatal "Unable to get Wi-Fi scan results"

if ! printf '%s\n' "${scan_results}" | awk -F '\t' '
function json_string(value, result, i, character, code, control) {
    result = "\""
    for (i = 1; i <= length(value); i++) {
        character = substr(value, i, 1)
        if (character == "\"" || character == "\\") {
            result = result "\\" character
        } else {
            for (code = 1; code < 32; code++) {
                control = sprintf("%c", code)
                if (character == control) {
                    result = result sprintf("\\u%04x", code)
                    character = ""
                    break
                }
            }
            if (character == sprintf("%c", 127)) {
                result = result "\\u007f"
            } else if (character != "") {
                result = result character
            }
        }
    }
    return result "\""
}

NR == 1 {
    header = tolower($0)
    if (index(header, "bssid") == 0 || index(header, "frequency") == 0 || index(header, "signal level") == 0) {
        exit 1
    }
    print "["
    next
}

{
    if (NF < 5 || $1 !~ /^[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]$/ ||
        $2 !~ /^[0-9]+$/ || $3 !~ /^-?[0-9]+$/) {
        next
    }

    if (count > 0) {
        printf ","
    }
    printf "{\"ssid\":%s,\"bssid\":%s,\"frequency\":%d,\"signal_dbm\":%d,\"security\":%s}",
        json_string($5), json_string(tolower($1)), $2, $3, json_string($4)
    count++
    if (count >= 64) {
        exit
    }
}

END {
    if (NR == 0) {
        exit 1
    }
    print "]"
}
' > "${temporary_file}"; then
    usizofatal "Unable to read or parse Wi-Fi scan results; keeping previous cache"
fi

chmod 644 "${temporary_file}" || usizofatal "Unable to set Wi-Fi cache permissions"
mv -f "${temporary_file}" "${cache_file}" || usizofatal "Unable to update Wi-Fi scan cache"
trap - EXIT HUP INT TERM
usizolog "Updated Wi-Fi scan cache"
