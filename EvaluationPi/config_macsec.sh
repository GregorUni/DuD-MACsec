sudo modprobe -r macsec
sudo modprobe -v macsec
echo -m "fehler1" >>log.txt 
sudo ip link add link $1 macsec0 type macsec cipher $2
echo -m "fehler2" >>log.txt 
sudo ip macsec add macsec0 tx sa 0 pn 1 on key 02 09876543210987654321098765432109
echo -m "fehler3" >>log.txt 
sudo ip macsec add macsec0 rx address $3 port 1
echo -m "fehler4" >>log.txt 
sudo ip macsec add macsec0 rx address $3 port 1 sa 0 pn 1 on key 01 12345678901234567890123456789012
echo -m "fehler5">>log.txt 
sudo ip link set dev macsec0 up
echo -m "fehler6">>log.txt 
sudo ifconfig macsec0 $4/24
sudo ip link set dev macsec0 mtu 1514
sudo ip link set macsec0 type macsec encrypt $5

