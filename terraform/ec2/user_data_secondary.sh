#!/bin/bash
# Configure the secondary DNS server
# Variables
ZONE="10.0.1"
DOMAIN_NAME="noamdahan.link"

PRIMARY_IP_ADDRESS="${ZONE}.11"
SECONDARY_IP_ADDRESS="${ZONE}.12"
WEBSERVER_IP_ADDRESS="${ZONE}.13"

reversed=$(echo $ZONE | awk -F . '{print $3"."$2"."$1}')
REVERSE_ZONE="${reversed}.in-addr.arpa"

PRIMARY_HOSTNAME="ns1.${DOMAIN_NAME}"
SECONDARY_HOSTNAME="ns2.${DOMAIN_NAME}"

# Update the hosts file
cat <<EOT > /etc/hosts
127.0.0.1 localhost
${SECONDARY_IP_ADDRESS} ${SECONDARY_HOSTNAME} ${SECONDARY_HOSTNAME%%.*}
EOT

# Update the hostname file
echo "${SECONDARY_HOSTNAME%%.*}" >/etc/hostname
hostname -F /etc/hostname

# Install BIND
sudo apt update
sudo apt install -y bind9 bind9utils bind9-doc

# Configure the BIND server
cat <<EOT > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        recursion no;
        allow-transfer { 10.0.1.12; }; 

        dnssec-validation auto;

        auth-nxdomain no;    
        listen-on-v6 { any; };
};
EOT

# Configuring the local config file
cat <<EOT > /etc/bind/named.conf.local
zone "${DOMAIN_NAME}" {
        type slave;
        file "/var/cache/bind/db.${DOMAIN_NAME}";
        masters { ${PRIMARY_IP_ADDRESS}; };
};

zone "${REVERSE_ZONE}" {
        type slave;
        file "/var/cache/bind/db.${REVERSE_ZONE}";
        masters { ${PRIMARY_IP_ADDRESS}; };
};
EOT
# We do not actually have to do any of the actual zone
# file creation on the secondary machine because, 
# this server will receive the zone
# files from the primary server. So we are ready to test.
sudo named-checkconf
sudo service bind9 restart
