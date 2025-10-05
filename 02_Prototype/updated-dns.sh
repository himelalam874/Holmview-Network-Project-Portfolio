#!/bin/bash
set -e

echo "[*] Installing bind9..."
sudo apt update -y
sudo apt install -y bind9 bind9utils

echo "[*] Configuring named.conf.options..."
sudo bash -c 'cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };
    forwarders {
        1.1.1.1;
        8.8.8.8;
    };
    dnssec-validation auto;
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF'

echo "[*] Configuring named.conf.local..."
sudo bash -c 'cat >/etc/bind/named.conf.local <<EOF
# Forward zones
zone "admin.local" { type master; file "/etc/bind/db.admin.local"; };
zone "staff.local" { type master; file "/etc/bind/db.staff.local"; };
zone "student.local" { type master; file "/etc/bind/db.student.local"; };
zone "guest.local" { type master; file "/etc/bind/db.guest.local"; };
zone "iot.local" { type master; file "/etc/bind/db.iot.local"; };
zone "infra.local" { type master; file "/etc/bind/db.infra.local"; };
zone "teacher.local" { type master; file "/etc/bind/db.teacher.local"; };

# Reverse zones
zone "10.168.192.in-addr.arpa" { type master; file "/etc/bind/db.192.168.10"; };   # admin
zone "20.168.192.in-addr.arpa" { type master; file "/etc/bind/db.192.168.20"; };   # staff
zone "30.10.10.in-addr.arpa"    { type master; file "/etc/bind/db.10.10.30"; };    # student
zone "40.10.10.in-addr.arpa"    { type master; file "/etc/bind/db.10.10.40"; };    # guest
zone "50.10.10.in-addr.arpa"    { type master; file "/etc/bind/db.10.10.50"; };    # IOT
zone "60.10.10.in-addr.arpa"    { type master; file "/etc/bind/db.10.10.60"; };    # infra
zone "70.10.10.in-addr.arpa"    { type master; file "/etc/bind/db.10.10.70"; };    # teacher
EOF'

echo "[*] Function to create forward and reverse zone files..."
create_zone_files() {
    zone_name=$1
    ns_ip=$2
    forward_file=$3
    reverse_file=$4
    shift 4
    hosts=("$@")
    today=$(date +%Y%m%d)
    serial="${today}01"

    # Forward zone file
    {
        echo "\$TTL 86400"
        echo "@   IN  SOA ns.${zone_name}. hostmaster.${zone_name}. ("
        echo "        $serial ; Serial"
        echo "        604800  ; Refresh"
        echo "        86400   ; Retry"
        echo "        2419200 ; Expire"
        echo "        86400 ) ; Negative Cache TTL"
        echo "@       IN  NS ns.${zone_name}."
        echo "ns      IN  A $ns_ip"
        for host in "${hosts[@]}"; do
            echo "$host"
        done
    } | sudo tee "$forward_file" > /dev/null

    # Reverse zone file
    {
        echo "\$TTL 86400"
        echo "@   IN  SOA ns.${zone_name}. hostmaster.${zone_name}. ("
        echo "        $serial ; Serial"
        echo "        604800  ; Refresh"
        echo "        86400   ; Retry"
        echo "        2419200 ; Expire"
        echo "        86400 ) ; Negative Cache TTL"
        echo "@       IN  NS ns.${zone_name}."
        # Do NOT put "ns IN A ..." in reverse zone, only PTR records
        for host in "${hosts[@]}"; do
            ip=$(echo $host | awk '{print $NF}')
            name=$(echo $host | awk '{print $1}')
            last_octet=$(echo $ip | awk -F. '{print $NF}')
            echo "$last_octet IN PTR $name.${zone_name}."
        done
    } | sudo tee "$reverse_file" > /dev/null
}

echo "[*] Creating all zones..."
create_zone_files "admin.local" "192.168.10.100" "/etc/bind/db.admin.local" "/etc/bind/db.192.168.10" \
    "server1 IN A 192.168.10.10" "pc1 IN A 192.168.10.20"

create_zone_files "staff.local" "192.168.20.100" "/etc/bind/db.staff.local" "/etc/bind/db.192.168.20" \
    "hr IN A 192.168.20.10" "finance IN A 192.168.20.20"

create_zone_files "student.local" "10.10.30.100" "/etc/bind/db.student.local" "/etc/bind/db.10.10.30" \
    "lab1 IN A 10.10.30.10" "lab2 IN A 10.10.30.20"

create_zone_files "guest.local" "10.10.40.100" "/etc/bind/db.guest.local" "/etc/bind/db.10.10.40" \
    "wifi1 IN A 10.10.40.10" "wifi2 IN A 10.10.40.20"

create_zone_files "iot.local" "10.10.50.100" "/etc/bind/db.iot.local" "/etc/bind/db.10.10.50" \
    "cam1 IN A 10.10.50.10" "sensor1 IN A 10.10.50.20"

create_zone_files "infra.local" "10.10.60.100" "/etc/bind/db.infra.local" "/etc/bind/db.10.10.60" \
    "router1 IN A 10.10.60.10" "switch1 IN A 10.10.60.20"

create_zone_files "teacher.local" "10.10.70.100" "/etc/bind/db.teacher.local" "/etc/bind/db.10.10.70" \
    "teacher1 IN A 10.10.70.10" "teacher2 IN A 10.10.70.20"

echo "[*] Setting permissions..."
sudo chown root:bind /etc/bind/db.*.local
sudo chmod 640 /etc/bind/db.*.local

echo "[*] Restarting named service..."
sudo systemctl enable named
sudo systemctl restart named

echo "[*] DNS setup complete!"

echo "[*] Testing DNS resolution for server1.admin.local..."
dig @localhost server1.admin.local A +short

if [ $? -eq 0 ]; then
    echo "[*] DNS test succeeded."
else
    echo "[!] DNS test failed."
fi