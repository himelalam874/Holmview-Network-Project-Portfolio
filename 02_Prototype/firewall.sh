#!/bin/bash

nft flush ruleset

nft -f - << 'EOF'
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "enp0s3" masquerade
    }
}

table inet filter {
    chain forward {
        type filter hook forward priority 0;

        ct state established,related accept

        iifname "vlan10" accept

        iifname "vlan20" oifname "enp0s3" accept
        iifname "vlan20" oifname "vlan20" accept

        iifname "vlan30" oifname "enp0s3" accept
        iifname "vlan30" oifname "vlan30" accept

        iifname "vlan40" oifname "enp0s3" accept

        iifname "vlan50" oifname "enp0s3" accept
        iifname "vlan50" oifname "vlan50" drop

        iifname "vlan10" oifname "vlan60" accept
        iifname "vlan60" oifname "vlan60" accept

        limit rate 5/second log prefix "DROP-FW: " flags all
        drop
    }
}
EOF
