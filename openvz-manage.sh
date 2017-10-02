#!/bin/bash
#open vz container managment and monitoring script


####### Functions ##########



####### Container Managment #######

cont-create () {
  clear
  PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
  # Generate random 12 char alpna numeric string for root password

  echo "Hostname: "
  read HOST
  echo "IP address: "
  read IP
  echo "OS available templates $(ls -la /vz/template/cache/)"
  ID=$(expr `echo $IP | awk -F"." '{print $1 + $2 + $3 + $4}'` + 1000)
  echo "Disk space soft/hard limits in format (6G:8G): "
  read DISK
  echo "RAM : "
  read RAM
  SWAP=$(($RAM * 2))

  vzctl create $ID --ostemplate centos-7.tar.gz --config basic > /dev/null
  vzctl set $ID --hostname $HOST --save > /dev/null
  vzctl set $ID --ipadd $IP --save > /dev/null
  vzctl set $ID --nameserver 8.8.8.8 --save > /dev/null
  vzctl set $ID --onboot yes --save > /dev/null
  vzctl set $ID --iolimit 10 --save > /dev/null
  vzctl set $ID --userpasswd root:${PASS}
  vzctl set $ID --ram $RAM --swap $SWAP --save >/dev/null
  vzctl set $ID --diskspace $DISK --save > /dev/null
  vzctl start $ID > /dev/null
  echo "Container is now created and running.."
  vzlist $ID
  echo "==================================="
  echo "Root Password : $PASS "
}


cont-delete () {
 echo "Conatiner ID to delete: "
 read CONT

 vzctl stop $CONT
 if [ $? != '0' ]; then
   echo "Please double check the container ID"
 fi
 vzctl destroy $CONT > /dev/null
 echo "$CONT is now deleted"
 vzctl status $CONT

}

cont-suspend () {
 clear
 echo "1 to Suspend container.. "
 echo "2 to Restore container.. "
 read CHOICE
case $CHOICE in
1)
 echo "Container ID to suspend"
 read CONTID
 vzctl chkpnt $CONTID > /dev/null
 echo "$CONTID is now suspended"
 ;;
2)
 echo "Container ID to restore"
 read CONTID
 vzctl restore $CONTID > /dev/null
 echo "$CONTID is now up and running"
 vzlist $CONTID
 ;;
*) echo "Only 1 or 2.."
 ;;
esac
}

############ Container Monitoring ############

load-check () {

  for CT in $(vzlist -H -o ctid); do
    VAR=`vzctl exec $CT uptime | awk -F" " '{print $8, $9, $10}'`
    if [ `echo $VAR | awk -F" " '{print $1}' | awk -F"." '{print $1}'` -gt 5 ]; then
      tput setaf 1; echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')";echo $VAR ; tput sgr0
      echo "========================="
    else
      echp "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"
      echo $VAR
      echo "========================="
    fi
  done
}


disk-check () {

  for CT in $(vzlist -H -o ctid); do
    VAR=`vzctl exec $CT df -h | head -2 | tail -1 | awk -F" " '{print $5}' | fold -w 2 | head -1`
    if [ $VAR -gt 85 ]; then
      tput setaf 1; echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"; vzctl exec $CT df -h | head -2 | tail -1; tput sgr0
      echo "=========================="
    else
      echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"
      vzctl exec $CT df -h | head -2 | tail -1
      echo "=========================="
    fi
  done
}

memory-check () {

  for CT in $(vzlist -H -o ctid); do
    USAGE=`vzctl exec $CT free -h | head -2 | tail -1 | awk -F" " '{print $3}'`
    FREE=`vzctl exec $CT free -h | head -2 | tail -1 | awk -F" " '{print $2}'`
    PERC=$((100*`echo $USAGE | sed 's/[a-zA-Z$]//g'`/`echo $FREE | sed 's/[a-zA-Z$]//g'`))
    if [ $PERC -gt 90 ]; then
      tput setaf1; echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"; vzctl exec $CT free -h | head -2 | tail -1; tput sgr0
      echo "=========================="
    else
      echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"
      vzctl exec $CT free -h | head -2 | tail -1
      echo "=========================="
    fi
done
}

trafic-check () {

  for CT in $(vzlist -H -0 ctid); do
    echo "==========================="
    echo "$CT $(vzlist -H $CT | awk -F" " '{print $5}')"
    TRIN=`vzctl exec $CT cat /proc/net/dev | grep venet0: | awk -F" " '{print $2}'`
    TROUT=`vzctl exec $CT cat /proc/net/dev | grep venet0: | awk -F" " '{print $10}'`
    echo "Traffic (send/receive): "
    echo "IN: $((($TRIN/1000)/1000)) MB"
    echo "OUT: $((($TROUT/1000)/1000)) MB"
  done
}


start () {
  clear
  echo "  OpenVZ control script usage:  "
  echo "================================"
  echo "--cont-create - Create container"
  echo "--cont-delete - Delete container"
  echo "--monitor - Monitor cont usage  "
  echo "--suspend - Suspend/restore cont"
  echo "================================"

}

########### Script start #############


if [ $# -eq 0 ] || [ $# -gt 1 ]; then
  start
elif [ $1 == "--cont-create" ]; then
  cont-create
elif [ $1 == "--cont-delete" ]; then
  cont-delete
elif [ $1 == "--suspend" ]; then
  cont-suspend
elif [ $1 == "--monitor" ]; then
  echo "What do you want to check"
  echo "1) load average"
  echo "2) disk usage  "
  echo "3) bandwith usage"
  echo "4) memory usage  "
  read CHOICE2

  case $CHOICE2 in
  1) load-check ;;
  2) disk-check ;;
  3) trafic-check ;;
  4) memory-check ;;
  *) echo "Please choose valid option" ;;
  esac
else
  echo "Please choose valid option"
  start
fi
