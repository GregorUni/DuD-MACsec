#!/bin/bash

EVA_DIR=eva
FPREFIX=$(date +%s)
DEST_IP=10.10.12.2
REMOTE_IP=141.76.55.43
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

init() {
    if [ ! -d "$EVA_DIR" ]; then
        mkdir $EVA_DIR
    fi
    init_remote
}

init_remote() {
 	echo -e "${GREEN}Init Remote${NC}"
    ssh root@$REMOTE_IP "killall -q iperf3"
    ssh root@$REMOTE_IP "nohup iperf3 -s > /dev/null 2>&1 &"
}

make_info() {
  echo -e "${GREEN}Write current info"
  INFO_FILE=$EVA_DIR/final-$FPREFIX-$1-$2.info

  tc qdisc > $INFO_FILE
	ip link show macsec0 >> $INFO_FILE
	ip link show eno1>> $INFO_FILE
	#ip macsec show >> $INFO_FILE
}

eva_ping() {
  #echo -e "${GREEN}Start RTT Evaluation of $1 with MTU $2${NC}"
  PING_FILE=$EVA_DIR/final-$FPREFIX-$1-$2-ping.txt
	sleep 4
	# somehow you cant ping with a packet size of 16. There is a bug with the -A optional. anyways macsec only accepts a packet size of min 46

        #sudo timeout 360 ping -A $3 -c 50000 -s $((( $2 - 28 ))) # packet sizes to test -> 16 86 214 470 982 1358 1472
	#sudo timeout 360 ping -A $3 -c 50000 -s $((( 16 - 8 )))   # cause of a bug you have to configure the packet size this way

	sudo timeout 60 ping -A $3 -c 5 -s $((( 106 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 5 -s $((( 234 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 5 -s $((( 490 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 5 -s $((( 1002 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 5 -s $((( 1378 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 5 -s $((( 1492 - 28 ))) >> $PING_FILE #somehow this doesnt work(maybe the packetsize is to big for the mtu?)
}


eva_iperf() {
    echo -e "${GREEN}Start Bandwith Evaluation of $2 with MTU $3${NC}"
    BANDWIDTH_FILE=$EVA_DIR/final-$FPREFIX-$1-$2-$3iperf.json

    echo -n "[" > $BANDWIDTH_FILE # Clear file

    for i in `seq 1 $1`; do
        echo -e "Start iperf3 #$i"
        sudo timeout 20 iperf3 -Jc $4 >> $BANDWIDTH_FILE
        if [ $? -ne 0 ]; then
            echo -e "${RED}iperf3 error${NC}"
            # i have to write a more complex error method so that if an error occurs the macsec module is loaded again (with a 60 sec pause)
        fi

        if [ $1 -eq $i ]; then
            echo -ne "]" >> $BANDWIDTH_FILE
        else
            echo -ne "," >> $BANDWIDTH_FILE
        fi;
    done
}
	

eva() {
#frame sizes to test-> 60 128 256 512 1024 1400 1514
	 echo -e "Erster Parameter:$1 Zweiter:$2 Dritter:$3 Vierter:$4 Fünfter: $5"

	if [[ $5 == mwe ]]; then #case macsec with aes(gcm) without encryption 
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_without_encryption.sh"
                config_macsec_without_encryption
                make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP
	

	elif [[ $5 == med ]]; then #case macsec with aes(gcm) and encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_encryption_default.sh"
		config_macsec_encryption_default
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == cwe ]]; then #case macsec with chachapoly without encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_chacha_without_encryption.sh"
		config_macsec_chacha_without_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == mce ]]; then #case macsec with chachapoly and encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_chacha_encryption.sh"
		config_macsec_chacha_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == awe ]]; then #case macsec with aegis128l without encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_aegis128l_without_encryption.sh"
		config_macsec_aegis128l_without_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP

		
	elif [[ $5 == ae ]]; then #case macsec with aegis128l with encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_aegis128l_encryption.sh"
		config_macsec_aegis128l_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == mme ]]; then  #case macsec with morus640 with encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_morus640_encryption.sh"
		config_macsec_morus640_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == mmwe ]]; then  #case macsec with morus640 without encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh /home/test2/DuD-MACsec/EvaluationPC/config_macsec_morus640_without_encryption.sh"
		config_macsec_morus640_without_encryption
		make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP

	
	elif [[ $5 == m ]]; then  #case macsec original with encryption
		IP=$DEST_IP
		ssh root@$REMOTE_IP "cd /home/test2/DuD-MACsec/macsec/orig/ ; sh config_macsec_orig_with_encryption_remote.sh"
		config_macsec_orig_with_encryption
		make_info $2 $4
		#sudo ip link set dev eno1 mtu 60
                #eva_iperf $1 $2 60 $DEST_IP
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	elif [[ $5 == mw ]]; then  #case macsec original without encryption
		echo -e "mtu_config"
		ssh root@$REMOTE_IP "cd /home/test2/DuD-MACsec/macsec/orig/ ; sh config_macsec_orig_without_encryption_remote.sh" 
		echo -e "mtu_config is "
		config_macsec_orig_without_encryption
		make_info $2 $4
		#sudo ip link set dev eno1 mtu 60
                #eva_iperf $1 $2 60 $DEST_IP
		mtu_config_for_iperf3 $1 $2 164 $DEST_IP
		mtu_config_for_iperf3 $1 $2 292 $DEST_IP
		mtu_config_for_iperf3 $1 $2 548 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1060 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1436 $DEST_IP
		mtu_config_for_iperf3 $1 $2 1550 $DEST_IP
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $3 $DEST_IP m
		eva_ping $2 $4 $IP


	else    #case no macsec no encryption
		echo -e "ethernet"
		IP=169.254.234.92
                make_info $2 $4
		mtu_config_for_iperf3 $1 $2 164 169.254.234.92
		mtu_config_for_iperf3 $1 $2 292 169.254.234.92
		mtu_config_for_iperf3 $1 $2 548 169.254.234.92
		mtu_config_for_iperf3 $1 $2 1060 169.254.234.92
		mtu_config_for_iperf3 $1 $2 1436 169.254.234.92
		mtu_config_for_iperf3 $1 $2 1550 169.254.234.92
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $4"
		sudo ip link set dev eno1 mtu $4
		mtu_config_for_iperf3 $1 $2 $4 169.254.234.92 m
		 eva_ping $2 $4 169.254.234.92

	fi
}

mtu_config_for_iperf3()
{
#third value + 36 if the mtu of macsec0 is changed
echo -e "mtu_config for iperf3"
	if [[ $5 == m ]]; then
		ssh root@$REMOTE_IP "sudo ip link set dev macsec0 mtu $3"
		sudo ip link set dev macsec0 mtu $3


	else
		ssh root@$REMOTE_IP "sudo ip link set dev eno1 mtu $3"
		sudo ip link set dev eno1 mtu $3
		ssh root@$REMOTE_IP "sudo ip link set dev macsec0 mtu $((( $3  - 36 )))"
		sudo ip link set dev macsec0 mtu $((( $3  - 36)))
	fi 
sleep 4
eva_iperf $1 $2 $3 $4


}



config_macsec_without_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo ip link add link eno1 macsec0 type macsec
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
	sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt off
}

config_macsec_encryption_default()
{

	sudo modprobe -r macsec
	cd /home/test1/DuD-MACsec/macsec ; sh conf-macsec.sh
	cd /home/test1/DuD-MACsec/EvaluationPC/
	sudo modprobe -v macsec
	sudo ip link add link eno1 macsec0 type macsec
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
	sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt on
}

config_macsec_chacha_without_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v chacha20poly1305
	sudo ip link add link eno1 macsec0 type macsec cipher chacha-poly-256
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt off
}

config_macsec_chacha_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v chacha20poly1305
	sudo ip link add link eno1 macsec0 type macsec cipher chacha-poly-256
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt on
}

config_macsec_aegis128l_without_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v aegis128l
	sudo ip link add link eno1 macsec0 type macsec cipher aegis128l-128
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt off
}

config_macsec_aegis128l_encryption()
{
sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v aegis128l
	sudo ip link add link eno1 macsec0 type macsec cipher aegis128l-128
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt on

}

config_macsec_morus640_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v morus640
	sudo ip link add link eno1 macsec0 type macsec cipher morus640-128
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt on
}
config_macsec_morus640_without_encryption()
{
	sudo modprobe -r macsec
	sudo modprobe -v macsec
	sudo modprobe -v morus640
	sudo ip link add link eno1 macsec0 type macsec cipher morus640-128
	sudo ip macsec add macsec0 tx sa 0 pn 1 on key 01 12345678901234567890123456789012
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1
	sudo ip macsec add macsec0 rx address ec:b1:d7:4b:bc:fd port 1 sa 0 pn 1 on key 02 09876543210987654321098765432109
	sudo ip link set dev macsec0 up
	sudo ifconfig macsec0 10.10.12.1/24
	sudo ip link set dev macsec0 mtu 1514
	sudo ip link set macsec0 type macsec encrypt off
}
config_macsec_orig_with_encryption()
{
	cd /home/test1/DuD-MACsec/macsec/orig/ ; sh config_macsec_orig_with_encryption.sh
	cd /home/test1/DuD-MACsec/EvaluationPC/
	#alias proj="cd ../../EvaluationPC/"
}

config_macsec_orig_without_encryption()
{
	cd /home/test1/DuD-MACsec/macsec/orig/; sh config_macsec_orig_without_encryption.sh
	cd /home/test1/DuD-MACsec/EvaluationPC/

}

# first parameter is the value for the amount of tests
# second parameter give a short explanation
# third parameter gives the macsec0 mtu-> third parameter isnt used...
# fourth parameter eno 1
init
make_info
eva $1 "no-macsec" 1000 1464
eva $1 "no-macsec" 1000 1500
eva $1 "no-macsec" 1000 2932
eva $1 "orig" 1464 1500 m #
eva $1 "orig" 1464 1500 mw #
eva $1 "orig-jumbo" 1500 9000 m #
eva $1 "orig-jumbo-without-encryption" 1500 9000 mw # iperf3 cases are redundant (except the last one)
eva $1 "orig-jumbo" 2936 9000 m #
eva $1 "orig-jumbo-without-encryption" 2936 9000 mw #
#testcases with frag 
eva $1 "macsec-aesgcm-e-1500" 1500 1500 med 
eva $1 "macsec-aesgcm-we-1500" 1500 1500 mwe
eva $1 "macsec-chachapoly-we-1500" 1500 1500 cwe
eva $1 "macsec-chachapoly-e-1500" 1500 1500 mce
eva $1 "macsec-aegis128l-e-1500" 1500 1500 ae
eva $1 "macsec-aegis128l-we-1500" 1500 1500 awe
eva $1 "macsec-morus640-e-1500" 1500 1500 mme
eva $1 "macsec-morus640-we-1500" 1500 1500 mmwe
############ 
eva $1 "macsec-aesgcm-e-1464" 1464 1500 med
eva $1 "macsec-aesgcm-we-1464" 1464 1500 mwe
eva $1 "macsec-chachapoly-we-1464" 1464 1500 cwe
eva $1 "macsec-chachapoly-e-1464" 1464 1500 mce
eva $1 "macsec-aegis128l-e-1464" 1464 1500 ae
eva $1 "macsec-aegis128l-we-1464" 1464 1500 awe
eva $1 "macsec-morus640-e-1464" 1464 1500 mme
eva $1 "macsec-morus640-we-1464" 1464 1500 mmwe
############
eva $1 "macsec-aesgcm-e-2936" 2936 1500 med #
eva $1 "macsec-aesgcm-we-2936" 2936 1500 mwe #
eva $1 "macsec-chachapoly-we-2936" 2936 1500 cwe #
eva $1 "macsec-chachapoly-e-2936" 2936 1500 mce #
eva $1 "macsec-aegis128l-e-2936" 2936 1500 ae #
eva $1 "macsec-aegis128l-we-2936" 2936 1500 awe #
eva $1 "macsec-morus640-e-2936" 2936 1500 mme #
eva $1 "macsec-morus640-we-2936" 2936 1500 mmwe #
# auch noch mit jumbo? also macsec-chachapoy-jumbo 1500,9000 und 2936, 9000?
# without macsec funktioniert nicht, weil mtu configuration
#denk dran, dass du vllt die ping größen und iperfgrößen ändern musst!

