eva_SimpleHTTPServer() {
echo -e "${GREEN}Start Bandwith Evaluation of $2 with MTU $3${NC}"
BANDWIDTH_FILE=$EVA_DIR/Http-$FPREFIX-$1-$2-$3.txt
Dstat_FILE=$EVA_DIR/Http-$FPREFIX-$1-$2-dstat.txt

dstat -N eth0,macsec0--noheaders --output $EVA_DIR/Http-$FPREFIX-$1-$2-dstat.csv > /dev/null 2>&1 &
ssh root@$REMOTE_IP "cd $Remote_PTH/DuD-MACsec/EvaluationPC/ ; nohup python -m SimpleHTTPServer >/dev/null 2>&1 &"
sudo timeout 30 wget http://$ETHERNET_IP:8000/test.iso >>$BANDWIDTH_FILE
kill `ps -ef | grep SimpleHTTPServer | grep -v grep | awk '{print $2}'`
kill `ps -ef | grep dstat | grep -v grep | awk '{print $2}'`
}
