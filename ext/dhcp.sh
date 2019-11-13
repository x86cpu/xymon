#!/bin/sh

#
#
#
# This required thie dhcping utility:
#
# http://www.mavetju.org/unix/general.php
#
#

COLUMN=dhcp
TIMEOUT=20
CLIENTIP=129.21.3.78
MACADDR="0:3:ba:14:a5:54"

MYIP=`hostname -i`

if [ "${MYIP}" = "192.168.66.10" ] ; then
   CLIENTIP="192.168.66.10"
   MACADDR="f4:6d:04:9e:8e:5a"
fi
if [ "${MYIP}" = "192.168.66.85" ] ; then
   CLIENTIP="192.168.66.85"
   MACADDR="b8:ca:3a:5e:cd:dd"
fi

# /usr/local/bin/dhcping -v -t 20 -s 129.21.13.174 -c 129.21.3.78 -h 0:3:ba:14:a5:54
#
# /usr/local/bin/dhcping -v -s 129.21.3.71 -c 129.21.3.78 -h 0:3:ba:14:a5:54
# Got answer from: 129.21.3.71


$BBHOME/bin/bbhostgrep --no-down ${COLUMN} |
while read L
do
     set $L
     IP="$1"
     HOSTNAME="$2"
     COLOR=green

#     if [ -f "$BBTMP/${COLUMN}.${HOSTNAME}.last" ] ; then
#        LAST=`/bin/cat $BBTMP/${COLUMN}.${HOSTNAME}.last`
#     else
#        LAST=0
#     fi
     /home/xymon/server/ext/ptime /usr/local/bin/dhcping -v -t ${TIMEOUT} -s $IP -c ${CLIENTIP} -h ${MACADDR} >$BBTMP/${COLUMN}.out 2>&1
     rc=$?
     if [ $rc -ne 0 ] ; then
        ${RM} -f $BBTMP/${COLUMN}.out
        sleep 10
        /home/xymon/server/ext/ptime /usr/local/bin/dhcping -v -t ${TIMEOUT} -s $IP -c ${CLIENTIP} -h ${MACADDR} >$BBTMP/${COLUMN}.out 2>&1
        rc=$?
     fi
     if [ $rc -ne 0 ] ; then
        ${RM} -f $BBTMP/${COLUMN}.out
        sleep 10
        /home/xymon/server/ext/ptime /usr/local/bin/dhcping -v -t ${TIMEOUT} -s $IP -c ${CLIENTIP} -h ${MACADDR} >$BBTMP/${COLUMN}.out 2>&1
        rc=$?
     fi
     ANS=`egrep "^Got answer" $BBTMP/${COLUMN}.out | /bin/awk '{printf $4}'`
##
# wrong host, try again...
     if [ "${ANS}" != "${IP}" ] ; then
        ${RM} -f $BBTMP/${COLUMN}.out
        sleep 10
        /home/xymon/server/ext/ptime /usr/local/bin/dhcping -v -t ${TIMEOUT} -s $IP -c ${CLIENTIP} -h ${MACADDR} >$BBTMP/${COLUMN}.out 2>&1
        rc=$?
     fi
     SEC=`egrep "^real" $BBTMP/${COLUMN}.out | awk '{printf $2}'`
     ANS=`egrep "^Got answer" $BBTMP/${COLUMN}.out | /bin/awk '{printf $4}'`

echo > $BBTMP/${COLUMN}.out
echo "Seconds: ${SEC}" >> $BBTMP/${COLUMN}.out

     if [ "${ANS}" != "${IP}" ] ; then
        COLOR=yellow
	MSG="DHCP query wrong host answered

`cat $BBTMP/${COLUMN}.out`
"
     fi

     if test $rc -ne 0
     then
        COLOR=red
	MSG="DHCP query failed

`cat $BBTMP/${COLUMN}.out`
"
     else
        COLOR=green
#        if [ "${LAST}" -gt 1 ] ; then
#		$RM $BBTMP/${COLUMN}.${HOSTNAME}.last
#        fi
	MSG="DHCP query succeeded

`cat $BBTMP/${COLUMN}.out`
"
  fi

  $BB $BBDISP "status $HOSTNAME.$COLUMN $COLOR `date`

  $MSG"
#  $RM $BBTMP/${COLUMN}.out
done

exit 0
