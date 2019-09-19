EVA_DIR=test
FPREFIX=$(date +%s)
DEST_IP=10.10.12.2
ETHERNET=169.254.248.66
INTERNET=141.76.55.44
RED='\033[0;31m'
NC='\033[0m'
eva_SimpleHTTPServer() {
echo -e "${GREEN}Start Bandwith Evaluation of $2 with MTU $3${NC}"
BANDWIDTH_FILE=$EVA_DIR/Http-$FPREFIX-wget.txt
Dstat_FILE=$EVA_DIR/Http-$FPREFIX-dstat.txt
if [ ! -d "$BANDWIDTH_FILE" ]; then
        touch $BANDWIDTH_FILE
    fi
dstat -N eth0,macsec0--noheaders --output $EVA_DIR/Http-$FPREFIX-dstat.csv > /dev/null 2>&1 &
ssh root@$INTERNET "cd /home/test2 ; nohup python -m SimpleHTTPServer >/dev/null 2>&1 &"

sleep 4
for i in `seq 1 $1`; do
echo -e "Start Http Test #$i"
wget_output=$(timeout 60 wget http://$DEST_IP:8000/test.iso --progress=dot:giga -a $BANDWIDTH_FILE)
if [ $? -ne 0 ]; then
            echo -e "${RED}Http error${NC}"
        fi

rm -f test.iso


done

ssh root@$INTERNET "kill -9 \$(ps -aux | grep SimpleHTTPServer | grep -v grep | awk '{print \$2}')"
sudo kill `ps -ef | grep dstat | grep -v grep | awk '{print $2}'`
}

#BANDWIDTH_FILE=$EVA_DIR/Http-$FPREFIX-$1-$2-$3.txt
#Dstat_FILE=$EVA_DIR/Http-$FPREFIX-$1-$2-dstat.txt
#"kill -9 \$(ps -aux | grep SimpleHTTPServer | grep -v grep | awk '{print \$2}')"
#ssh root@141.76.55.44 "kill -9 \$(ps -ef | grep SimpleHTTPServer | grep -v grep | awk '{print $2}')"
#wget_output=$(timeout 60 wget http://$DEST_IP:8000/test.iso -a $BANDWIDTH_FILE)
#wget_output=$(timeout 60 wget http://$DEST_IP:8000/test.iso | grep -Eo '\(+[[:digit:]]\.*[[:digit:]]*\%\)' >>BANDWIDTH_FILE)
#grep -Eo '\(+[[:digit:]]\.*[[:digit:]]*\%\)'

eva_SimpleHTTPServer $1 "orig" 1464 1500 m
