#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

#ensure script is running correctly
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

########################-overview interfaces-######################################################
# eth0 - uplink
# eth1 - management interfaces 10.7.7.0/24
# eth2 - internet only interface 10.8.8.0/24
###################################################################################################

########################-configuration starts here-################################################
configure

######## Interfaces
echo "[*] configuring interfaces"
set interfaces ethernet eth0 description 'uplink'
set interfaces ethernet eth0 address dhcp
commit
echo "[V] eth0 configured"
set interfaces ethernet eth2 description 'inetonly'
set interfaces ethernet eth2 address '10.8.8.1/24'
commit
echo "[V] eth2 configured"

######## DHCP
echo "[*] configuring DHCP"
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 default-router '10.8.8.1'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 dns-server '8.8.8.8'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 dns-server '8.8.4.4'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 domain-name 'inetonly'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 lease '86400'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 range 0 start '10.8.8.2'
set service dhcp-server shared-network-name inetonly subnet 10.8.8.0/24 range 0 stop '10.8.8.254'
commit
echo "[V] DHCP configured"

######## NAT
echo "[*] configuring NAT"
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '10.8.8.0/24'
set nat source rule 100 translation address masquerade
commit
echo "[V] NAT configured"

save

######## NTP
echo "[*] configuring NTP"
set system ntp server '0.pool.ntp.org'
set system ntp server '1.pool.ntp.org'
set system ntp server '2.pool.ntp.org'
commit
echo "[V] NTP configured"

######## DNS
echo "[*] configuring DNS"
set system name-server '8.8.8.8'
set system name-server '8.8.4.4'
commit
echo "[V] DNS configured"

######## Firewall
echo "[*] configuring firewall"

######## global states
set firewall state-policy established action accept
set firewall state-policy related action accept
set firewall state-policy invalid action drop
set firewall source-validation strict

######## define groups
set firewall group network-group internalranges
set firewall group network-group internalranges network '10.0.0.0/8'
set firewall group network-group internalranges network '172.16.0.0/12'
set firewall group network-group internalranges network '192.168.0.0/16'
commit

set firewall group address-group vyos-updates address '185.144.208.249'
set firewall group address-group vyos-updates description 'downloads.vyos.io'
commit

set firewall group address-group dns-servers address '8.8.8.8'
set firewall group address-group dns-servers address '8.8.4.4'
set firewall group address-group dns-servers description 'Google DNS'
commit

######## define zone policies
set zone-policy zone local local-zone
set zone-policy zone local default-action drop

set zone-policy zone uplink
set zone-policy zone uplink interface eth0
set zone-policy zone uplink default-action drop
set zone-policy zone uplink description 'uplink zone'

set zone-policy zone mgmt
set zone-policy zone mgmt interface eth1
set zone-policy zone mgmt default-action drop
set zone-policy zone mgmt description 'mgmt zone'

set zone-policy zone inetonly
set zone-policy zone inetonly interface eth2
set zone-policy zone inetonly default-action drop
set zone-policy zone inetonly description 'internet only'
commit

save

######## configure firewall rules per zone
set firewall name uplinkTOinetonly default-action drop
set firewall name uplinkTOmgmt default-action drop
commit

set firewall name mgmtTOuplink default-action drop
set firewall name mgmtTOinetonly default-action drop

set firewall name localTOuplink default-action drop

set firewall name localTOuplink rule 10 action accept
set firewall name localTOuplink rule 10 protocol udp
set firewall name localTOuplink rule 10 destination port 123

set firewall name localTOuplink rule 20 action accept
set firewall name localTOuplink rule 20 protocol tcp
set firewall name localTOuplink rule 20 destination port 443
set firewall name localTOuplink rule 20 destination group address-group vyos-updates
commit

set firewall name localTOuplink rule 30 action accept
set firewall name localTOuplink rule 30 protocol tcp_udp
set firewall name localTOuplink rule 30 destination port 53
set firewall name localTOuplink rule 30 destination group address-group dns-servers
commit

set firewall name inetonlyTOmgmt default-action drop

set firewall name inetonlyTOuplink default-action accept
set firewall name inetonlyTOuplink rule 10 action drop
set firewall name inetonlyTOuplink rule 10 protocol tcp_udp
set firewall name inetonlyTOuplink rule 10 destination group network-group internalranges

commit

######## apply rules to zones
set zone-policy zone uplink from inetonly firewall name inetonlyTOuplink
set zone-policy zone uplink from mgmt firewall name mgmtTOuplink
set zone-policy zone uplink from local firewall name localTOuplink

set zone-policy zone mgmt from inetonly firewall name inetonlyTOmgmt
set zone-policy zone mgmt from uplink firewall name uplinkTOmgmt

set zone-policy zone inetonly from uplink firewall name uplinkTOinetonly
set zone-policy zone inetonly from mgmt firewall name mgmtTOinetonly
commit
echo "[V] firewall configured"

save

exit

exit
