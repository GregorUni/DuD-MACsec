sudo rmmod /lib/modules/$(uname -r)/kernel/crypto/aegis128l.ko
sudo modprobe -r macsec
sudo modprobe -rf aegis128l
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) aegis128l.ko
sudo cp aegis128l.ko /lib/modules/$(uname -r)/kernel/crypto
sudo insmod /lib/modules/$(uname -r)/kernel/crypto/aegis128l.ko 
sudo modprobe -v aegis128l
cd /home/test1/linux-4.18.20/drivers/net 
sudo bash imkernel.sh
