#!/bin/bash

# Update the package manager
apt update

# Install the BIND DNS server
apt install -y bind9

# Configure BIND to act as a recursive resolver
cat << EOF > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";

        forwarders {
                10.0.2.11;    # Primary DNS
                10.0.2.12;    # Secondary DNS
        };

        recursion yes;

        allow-query { any; };
        allow-recursion { any; };
};
EOF

# Restart the BIND service to apply the new configuration
systemctl restart bind9
