#!/usr/bin/awk -f

function add_interface_missing() {
    if (!has_preup) print "PreUp = " updown " %i preup" > wgcnf;
    if (!has_postup) print "PostUp = " updown " %i up" > wgcnf;
    if (!has_predown) print "PreDown = " updown " %i down" > wgcnf;
    if (!has_postdown) print "PostDown = " updown " %i postdown" > wgcnf;
    if (!has_table) print "Table = " rtable > wgcnf;
    if (!has_preup || !has_postup || !has_predown || !has_postdown || !has_table) print "" > wgcnf;
}

function add_peer_missing() {
    # for NAT traversal
    if (!has_keepalive) print "PersistentKeepalive = 25" > wgcnf;
    if (!has_keepalive) print "" > wgcnf;
}

BEGIN {
    IGNORECASE = 1;
    if (!wgcnf) wgcnf = "/etc/wireguard/wg0.conf";
    if (!updown) updown = "/usr/local/sbin/usizo-eduvpn-up-down.sh";
    if (!rtable) rtable = 1;
}

{
    header = $0;
    sub(/^[[:space:]]*/, "", header);
    if (substr(header, 1, 1) == "[") {
        if (in_interface) add_interface_missing();
        if (in_peer) add_peer_missing();
        in_interface = (header == "[Interface]");
        in_peer = (header == "[Peer]");
    }
    if (in_interface && $0 ~ /^[[:space:]]*PreUp[[:space:]]*=/) has_preup = 1;
    if (in_interface && $0 ~ /^[[:space:]]*PostUp[[:space:]]*=/) has_postup = 1;
    if (in_interface && $0 ~ /^[[:space:]]*PreDown[[:space:]]*=/) has_predown = 1;
    if (in_interface && $0 ~ /^[[:space:]]*PostDown[[:space:]]*=/) has_postdown = 1;
    if (in_interface && $0 ~ /^[[:space:]]*Table[[:space:]]*=/) has_table = 1;
    if (in_peer && $0 ~ /^[[:space:]]*PersistentKeepalive[[:space:]]*=/) has_keepalive = 1;
    if (in_peer && $0 ~ /^[[:space:]]*ProxyEndpoint/) printf "#" > wgcnf;
    print $0 > wgcnf;
}

END {
    if (in_interface) add_interface_missing();
    if (in_peer) add_peer_missing();
    close(wgcnf);
}
