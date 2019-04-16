sudo modprobe -r macsec	
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) macsec.ko
sudo cp macsec.ko /lib/modules/$(uname -r)/kernel/drivers/net	
sudo modprobe -v macsec
