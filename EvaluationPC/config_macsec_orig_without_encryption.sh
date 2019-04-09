sudo modprobe -r macsec
#cd ~
#sudo cd /home/test-2/linux-stable-4.16.16/crypto
#sudo bash morus.sh
#sudo cd ~
sudo modprobe -v macsec
sudo ip link add link enx18d6c70c1682 macsec0 type macsec
sudo ip macsec add macsec0 tx sa 0 pn 1 on key 02 09876543210987654321098765432109
sudo ip macsec add macsec0 rx address 18:d6:c7:0c:0a:7e port 1
sudo ip macsec add macsec0 rx address 18:d6:c7:0c:0a:7e port 1 sa 0 pn 1 on key 01 12345678901234567890123456789012
sudo ip link set dev macsec0 up
sudo ifconfig macsec0 10.10.12.2/24
sudo ip link set dev macsec0 mtu 1514
sudo ip link set macsec0 type macsec encrypt off
