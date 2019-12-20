#!/bin/bash

EVA_DIR=final7
FPREFIX=$(date +%s)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#variables for host_pc
Host_PTH="/home/test1" #folder in which the git repository is located
HOST_MAC_ADR="ec:b1:d7:4b:bd:01" #mac adress of ethernet device
SOURC_IP=10.10.12.1 #name of ethernet interface
HOST_ETHERNET_NAME="eno1"

#variables for remote_pc
Remote_PTH="/home/test2" #folder in which the git repository is located
Remote_MAC_ADR="ec:b1:d7:4b:bc:fd" #mac adress of ethernet device
DEST_IP=10.10.12.2 #macsec ip
REMOTE_IP=141.76.55.44 #internet ip
ETHERNET_IP=169.254.248.68 #ethernet ip
REMOTE_ETHERNET_NAME="eno1" #name of ethernet interface

#Cipher configs for iproute2
AEGIS="aegis128l-128"
CHACHA="chacha-poly-256"
MORUS="morus640-128"
AES="default"
#with/without encryption
ON="on"
OFF="off"

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

  tc qdisc >> $INFO_FILE
	ip link show macsec0 >> $INFO_FILE
	ip link show eno1 >> $INFO_FILE
	#ip macsec show >> $INFO_FILE
	ifconfig >> $INFO_FILE
}

eva_ping() {
  #echo -e "${GREEN}Start RTT Evaluation of $1 with MTU $2${NC}"
  PING_FILE=$EVA_DIR/final-$FPREFIX-$1-$2-ping.txt
	sleep 4
	# somehow you cant ping with a packet size of 16. There is a bug with the -A optional. anyways macsec only accepts a packet size of min 46

        #sudo timeout 360 ping -A $3 -c 50000 -s $((( $2 - 28 ))) # packet sizes to test -> 16 86 214 470 982 1358 1472
	#sudo timeout 360 ping -A $3 -c 50000 -s $((( 16 - 8 )))   # cause of a bug you have to configure the packet size this way
	dstat -N $HOST_ETHERNET_NAME,macsec0--noheaders --output $EVA_DIR/ping-$FPREFIX-$1-$2-dstat.csv > /dev/null 2>&1 &	
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 106 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 234 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 490 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 1002 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 1378 - 28 ))) >> $PING_FILE
	sudo timeout 60 ping -A $3 -c 50000 -s $((( 1464 - 28 ))) >> $PING_FILE #somehow this doesnt work(maybe the packetsize is to big for the mtu?)
	sudo kill `ps -ef | grep dstat | grep -v grep | awk '{print $2}'`
}


eva_iperf() {
    echo -e "${GREEN}Start Bandwith Evaluation of $2 with MTU $3${NC}"
    BANDWIDTH_FILE=$EVA_DIR/final-$FPREFIX-$1-$2-$3-$5-iperf.json
    Dstat_FILE=$EVA_DIR/iperf3-$FPREFIX-$1-$2-dstat.txt
    echo -n "[" > $BANDWIDTH_FILE # Clear file
	dstat -N $HOST_ETHERNET_NAME,macsec0--noheaders --output $EVA_DIR/iperf3-$FPREFIX-$1-$2-dstat.csv > /dev/null 2>&1 &
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
	sudo kill `ps -ef | grep dstat | grep -v grep | awk '{print $2}'`
}

eva_SimpleHTTPServer() {
 echo -e "${GREEN}Start Bandwith Evaluation of $2 with MTU $3${NC}"
 echo -e "Erster Parameter:$1 Zweiter:$2 Dritter:$3 Vierter:$4 Fünfter: $5"
    BANDWIDTH_FILE=$EVA_DIR/http-$FPREFIX-$1-$2-$3-$5-wget.txt
    Dstat_FILE=$EVA_DIR/http-$FPREFIX-$1-$2-$3-$5-dstat.txt
	if [ ! -d "$BANDWIDTH_FILE" ]; then
	        touch $BANDWIDTH_FILE
	    fi
	
	dstat -N $HOST_ETHERNET_NAME,macsec0--noheaders --output $EVA_DIR/Http-$FPREFIX-$1-$2-$3-$5-dstat.csv > /dev/null 2>&1 &
	ssh root@$REMOTE_IP "cd /home/test2 ; nohup python -m SimpleHTTPServer >/dev/null 2>&1 &"
	sleep 4

	for i in `seq 1 $1`; do
	echo -e "Start Http Test #$i"
	wget_output=$(timeout 60 wget http://$4:8000/test.iso  --progress=dot:giga -a $BANDWIDTH_FILE)
	
	if [ $? -ne 0 ]; then
		echo -e "${RED}Http error${NC}"
	    fi

	rm -f test.iso


	done


	ssh root@$REMOTE_IP "kill -9 \$(ps -aux | grep SimpleHTTPServer | grep -v grep | awk '{print \$2}')"
	sudo kill `ps -ef | grep dstat | grep -v grep | awk '{print $2}'`
}
	

eva() {
#frame sizes to test-> 60 128 256 512 1024 1400 1514
	 echo -e "Erster Parameter:$1 Zweiter:$2 Dritter:$3 Vierter:$4 Fünfter: $5"

	if [[ $5 == mwe ]]; then #case macsec with aes(gcm) without encryption 
		IP=$DEST_IP
		#configure macsec device on remote computer and host computer
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $AES $HOST_MAC_ADR $DEST_IP $OFF"
                sh config_macsec.sh $HOST_ETHERNET_NAME $AES $Remote_MAC_ADR $SOURC_IP $OFF
                
		#set mtu for ethernet device and macsec0
		make_info $2 $4
		mtu_config_for_iperf3 $3 $4

		#start ping and iperf tests
		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4
		


	

	elif [[ $5 == med ]]; then #case macsec with aes(gcm) and encryption
		IP=$DEST_IP
		#loading macsec with fragmentation and crypto extension
		ssh root@$REMOTE_IP "cd $Remote_PTH/DuD-MACsec/macsec ; sh conf-macsec.sh;"
		cd /home/test1/DuD-MACsec/macsec ; sh conf-macsec.sh
		cd /home/test1/DuD-MACsec/EvaluationPC/
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $AES $HOST_MAC_ADR $DEST_IP $ON"
		sh config_macsec.sh $HOST_ETHERNET_NAME $AES $Remote_MAC_ADR $SOURC_IP $ON

		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4
		


	elif [[ $5 == cwe ]]; then #case macsec with chachapoly without encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $CHACHA $HOST_MAC_ADR $DEST_IP $OFF"
		sh config_macsec.sh $HOST_ETHERNET_NAME $CHACHA $Remote_MAC_ADR $SOURC_IP $OFF
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP # 1500 1500 ; 1464 1500 ; 2936 1500
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	elif [[ $5 == mce ]]; then #case macsec with chachapoly and encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $CHACHA $HOST_MAC_ADR $DEST_IP $ON"
		sh config_macsec.sh $HOST_ETHERNET_NAME $CHACHA $Remote_MAC_ADR $SOURC_IP $ON
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	elif [[ $5 == awe ]]; then #case macsec with aegis128l without encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $AEGIS $HOST_MAC_ADR $DEST_IP $OFF"
		sh config_macsec.sh $HOST_ETHERNET_NAME $AEGIS $Remote_MAC_ADR $SOURC_IP $OFF
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4

		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4

		
	elif [[ $5 == ae ]]; then #case macsec with aegis128l with encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $AEGIS $HOST_MAC_ADR $DEST_IP $ON"
		sh config_macsec.sh $HOST_ETHERNET_NAME $AEGIS $Remote_MAC_ADR $SOURC_IP $ON
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4

		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	elif [[ $5 == mme ]]; then  #case macsec with morus640 with encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $MORUS $HOST_MAC_ADR $DEST_IP $ON"
		sh config_macsec.sh $HOST_ETHERNET_NAME $MORUS $Remote_MAC_ADR $SOURC_IP $ON
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4

		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	elif [[ $5 == mmwe ]]; then  #case macsec with morus640 without encryption
		IP=$DEST_IP
		
		ssh root@$REMOTE_IP "sh $Remote_PTH/DuD-MACsec/EvaluationPC/remote_config_macsec.sh $REMOTE_ETHERNET_NAME $MORUS $HOST_MAC_ADR $DEST_IP $OFF"
		sh config_macsec.sh $HOST_ETHERNET_NAME $MORUS $Remote_MAC_ADR $SOURC_IP $OFF
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4

	
	elif [[ $5 == m ]]; then  #case macsec original with encryption

		
		ssh root@$REMOTE_IP "cd $Remote_PTH/DuD-MACsec/macsec/orig/ ; sh remote_orig_conf_macsec.sh $REMOTE_ETHERNET_NAME $HOST_MAC_ADR $DEST_IP $ON"
		cd $Host_PTH/DuD-MACsec/macsec/orig/ ; sh orig_conf_macsec.sh $HOST_ETHERNET_NAME $Remote_MAC_ADR $SOURC_IP $ON
		cd $Host_PTH/DuD-MACsec/EvaluationPC/
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $DEST_IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	elif [[ $5 == mw ]]; then  #case macsec original without encryption
		#loading original macsec module into kernel
		ssh root@$REMOTE_IP "cd $Remote_PTH/DuD-MACsec/macsec/orig/ ; sh remote_orig_conf_macsec.sh $REMOTE_ETHERNET_NAME $HOST_MAC_ADR $DEST_IP $OFF" 
		cd $Host_PTH/DuD-MACsec/macsec/orig/ ; sh orig_conf_macsec.sh $HOST_ETHERNET_NAME $Remote_MAC_ADR $SOURC_IP $OFF
		cd $Host_PTH/DuD-MACsec/EvaluationPC/
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4
		
		eva_ping $2 $4 $DEST_IP
		eva_iperf $1 $2 $3 $DEST_IP
		#eva_SimpleHTTPServer $1 $2 $3 $DEST_IP $4


	else    #case no macsec no encryption
		
		mtu_config_for_iperf3 $3 $4
		make_info $2 $4

		eva_ping $2 $4 $ETHERNET_IP
		eva_iperf $1 $2 $3 $ETHERNET_IP
		#eva_SimpleHTTPServer $1 $2 $3 $ETHERNET_IP $4

	fi
}

mtu_config_for_iperf3()
{
#third value + 36 if the mtu of macsec0 is changed
echo -e "mtu_config for iperf3"
echo -e "config for qdisc"

		ssh root@$REMOTE_IP "sudo ip link set dev $REMOTE_ETHERNET_NAME mtu $2"
		sudo ip link set dev $HOST_ETHERNET_NAME mtu $2
		ssh root@$REMOTE_IP "sudo ip link set dev macsec0 mtu $1"
		sudo ip link set dev macsec0 mtu $1
echo -e "config for qdisc"
		sudo tc qdisc replace dev $HOST_ETHERNET_NAME root pfifo_fast
		ssh root@$REMOTE_IP "sudo tc qdisc replace dev $REMOTE_ETHERNET_NAME root pfifo_fast"
		sudo tc qdisc replace dev macsec0 root pfifo_fast
		ssh root@$REMOTE_IP "sudo tc qdisc replace dev macsec0 root pfifo_fast"
sleep 4
echo -e "end mtu_config for iperf3"



}

#todo interface mit variablen versehen. path problem lösen. nur noch eine macsec script datei erstellen mit vielen verschiedenen variablen.
# first parameter is the value for the amount of tests
# second parameter give a short explanation
# third parameter gives the macsec0 mtu
# fourth parameter eno 1 mtu
init
make_info
#eva $1 "no-macsec-1464" 1000 1464
#eva $1 "no-macsec-1500" 1000 1500
#eva $1 "no-macsec-2928" 1000 2928
#eva $1 "orig-e" 1464 1500 m #
#eva $1 "orig-we" 1464 1500 mw #
#eva $1 "orig-jumbo" 1500 9000 m #
#eva $1 "orig-jumbo-without-encryption-1500" 1500 9000 mw # iperf3 cases are redundant (except the last one)
#eva $1 "orig-jumbo-2928" 2928 9000 m #
#eva $1 "orig-jumbo-without-encryption-2928" 2928 9000 mw #
#testcases with frag 
#eva $1 "macsec-aesgcm-e" 1464 1500 med 
#eva $1 "macsec-aesgcm-we" 1464 1500 mwe
#eva $1 "macsec-aesgcm-e-frag" 1500 1500 med
#eva $1 "macsec-chachapoly-e-frag" 1500 1500 mce 
#eva $1 "macsec-aesgcm-we-frag" 1500 1500 mwe
#eva $1 "macsec-aegis128l-e-frag" 1500 1500 ae
#eva $1 "macsec-morus640-e-frag" 1500 1500 mme
#eva $1 "macsec-aesgcm-e-jumbo" 1500 2928 med 
#eva $1 "macsec-aesgcm-we-jumbo" 1500 2928 mwe
#eva $1 "macsec-aesgcm-e-frag-jumbo" 2928 1500 med
#eva $1 "macsec-aesgcm-we-frag-jumbo" 2928 1500 mwe
#eva $1 "macsec-aesgcm-e-jumbo-Ethernet" 1500 9000 med
#eva $1 "macsec-aes-gcm-we-jumbo-Ethernet" 1500 9000 mwe
#eva $1 "macsec-aes-gcm-e-jumbo-MACsec-Ethernet" 2928 9000 med
eva $1 "macsec-aes-gcm-we-jumbo-MACsec-Ethernet" 2928 9000 mwe 
eva $1 "macsec-chachapoly-we-1500" 1464 1500 cwe
eva $1 "macsec-chachapoly-e-1500" 1464 1500 mce
eva $1 "macsec-aegis128l-e-1500" 1464 1500 ae
eva $1 "macsec-aegis128l-we-1500" 1464 1500 awe
#eva $1 "macsec-morus640-e-1500" 1464 1500 mme
eva $1 "macsec-morus640-we-1500" 1464 1500 mmwe
# auch noch mit jumbo? also macsec-chachapoy-jumbo 1500,9000 und 2936, 9000? 1500 1500; 1464 1500 , 2936 1500 ,
# without macsec funktioniert nicht, weil mtu configuration
#denk dran, dass du vllt die ping größen und iperfgrößen ändern musst!

