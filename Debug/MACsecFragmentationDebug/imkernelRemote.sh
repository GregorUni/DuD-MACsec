#!/bin/bash
sudo modprobe -r macsec
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) macsec.ko
sudo cp macsec.ko /lib/modules/$(uname -r)/kernel/drivers/net
sudo modprobe -v macsec
sudo ip link add link enx18d6c70c16d3 macsec0 type macsec 
sudo ip macsec add macsec0 tx sa 0 pn 1 on key 02 09876543210987654321098765432109
sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bd:01 port 1
sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bd:01 port 1 sa 0 pn 1 on key 01 12345678901234567890123456789012
sudo ip link set dev macsec0 up
sudo ifconfig macsec0 10.10.12.2/24
sudo ip link set macsec0 type macsec encrypt on
sudo ip link set macsec0 mtu 1436




