sudo modprobe -r macsec
sudo modprobe -v macsec
sudo ip link add link eno1 macsec0 type macsec cipher aegis128l-128
sudo ip macsec add macsec0 tx sa 0 pn 1 on key 02 09876543210987654321098765432109
sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bd:01 port 1
sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bd:01 port 1 sa 0 pn 1 on key 01 12345678901234567890123456789012
sudo ip link set dev macsec0 mtu 1514
sudo ip link set dev macsec0 up
sudo ifconfig macsec0 10.10.12.2/24
sudo ip link set macsec0 type macsec encrypt on

