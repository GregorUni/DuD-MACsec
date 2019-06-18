#!/bin/bash
sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.1.1.tar.xz
xz -d -v linux-5.1.1.tar.xz
sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.1.1.tar.sign
gpg --verify linux-5.1.1.tar.sign
cd linux-5.0
sudo cp -v /boot/config-$(uname -r) .config
sudo make menuconfig
sudo make -j $(nproc)
sudo make modules_install
sudo make install
sudo update-initramfs -c -k 5.0.0
sudo update-grub
sudo reboot
uname -mrs
