#!/bin/bash

# Variables
ZONE="10.0.1"
DOMAIN_NAME="noamdahan.link"

PRIMARY_IP_ADDRESS="${ZONE}.11"
SECONDARY_IP_ADDRESS="${ZONE}.12"
WEBSERVER_IP_ADDRESS="${ZONE}.13"

# External IP Addresses
PRIMARY_EXTERNAL_IP="13.48.175.147"
SECONDARY_EXTERNAL_IP="16.16.235.53"
WEBSERVER_EXTERNAL_IP="13.51.134.56"

reversed=$(echo $ZONE | awk -F . '{print $3"."$2"."$1}')
REVERSE_ZONE="${ZONE}.in-addr.arpa"

PRIMARY_HOSTNAME="ns1.${DOMAIN_NAME}"
SECONDARY_HOSTNAME="ns2.${DOMAIN_NAME}"

# Update the hosts file
cat <<EOT > /etc/hosts
127.0.0.1 localhost
${PRIMARY_IP_ADDRESS} ${PRIMARY_HOSTNAME} ${PRIMARY_HOSTNAME%%.*}
EOT

# Update the hostname file
echo "${PRIMARY_HOSTNAME%%.*}" > /etc/hostname
hostname -F /etc/hostname

# Install BIND
sudo apt update
sudo apt install -y bind9 bind9utils bind9-doc

# Configure the BIND server
cat <<EOT > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        recursion no;
        allow-transfer { none; };

        dnssec-validation auto;

        auth-nxdomain no;    
        listen-on-v6 { any; };
};
EOT

# Configuring the local file
cat <<EOT > /etc/bind/named.conf.local
zone "${DOMAIN_NAME}" {
        type master;
        file "/etc/bind/zones/db.${DOMAIN_NAME}";  
        allow-transfer { ${SECONDARY_IP_ADDRESS}; };
};

zone "${REVERSE_ZONE}" {
        type master;
        file "/etc/bind/zones/db.${REVERSE_ZONE}"; 
        allow-transfer { ${SECONDARY_IP_ADDRESS}; };
};

EOT
EOT


# Create the reverse zone file
sudo mkdir /etc/bind/zones
sudo cp /etc/bind/db.local /etc/bind/zones/db.${DOMAIN_NAME}
sudo cp /etc/bind/db.127 /etc/bind/zones/db.${ZONE}

# Create the zone file
cat <<EOT > /etc/bind/zones/db.${DOMAIN_NAME}
\$TTL    604800
@       IN      SOA     ${PRIMARY_HOSTNAME}. admin.${PRIMARY_HOSTNAME}. (
                 2021032401         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; Name Servers
@               IN      NS      ${PRIMARY_HOSTNAME}.
@               IN      NS      ${SECONDARY_HOSTNAME}.
; A records for the name servers
${PRIMARY_HOSTNAME}.    IN      A       ${PRIMARY_EXTERNAL_IP}
${SECONDARY_HOSTNAME}.  IN      A       ${SECONDARY_EXTERNAL_IP}

; Other A records
@      IN      A       ${WEBSERVER_EXTERNAL_IP}
www    IN      A       ${WEBSERVER_EXTERNAL_IP}
EOT

# Create the reverse zone file
cat <<EOT > /etc/bind/zones/db.${REVERSE_ZONE}
\$TTL    604800
@       IN      SOA    ${PRIMARY_HOSTNAME}. admin.${PRIMARY_HOSTNAME}. (
                 2021032401         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name Servers
        IN     NS      ${PRIMARY_HOSTNAME}.
        IN     NS      ${SECONDARY_HOSTNAME}.

; PTR records for the name servers
11      IN      PTR     ${PRIMARY_HOSTNAME%%.*}.
12      IN      PTR     ${SECONDARY_HOSTNAME%%.*}.
13     IN      PTR      www.${DOMAIN_NAME}.
EOT

sudo named-checkconf
sudo named-checkzone ${DOMAIN_NAME} /etc/bind/zones/db.${DOMAIN_NAME}
sudo named-checkzone ${REVERSE_ZONE} /etc/bind/zones/db.${REVERSE_ZONE}
sudo service bind9 restart