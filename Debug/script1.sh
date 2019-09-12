ip link add link eth1 macsec0 type macsec
ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
ip macsec add macsec0 rx address 18:d6:c7:0c:16:82 port 1
ip macsec add macsec0 rx address 18:d6:c7:0c:16:82 port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
ip link set dev macsec0 up
ifconfig macsec0 10.10.12.1/24
