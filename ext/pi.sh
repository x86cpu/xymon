#!/bin/sh

COLUMN=pi
SSH=/usr/bin/ssh 
SCP=/usr/bin/scp 

$BBHOME/bin/bbhostgrep --no-down=ssh --noextras ${COLUMN} |
while read L ; do
     set $L
     LINE=$L
     IP="$1"
     HOSTNAME="$2"
#     PORT=`echo ${LINE} | tr ' ' '\n' | egrep "^${COLUMN}:" | awk -F':' '{printf $2}'`
#
     PORT=22
     USER=pi

#     CMD="${SSH} -n -l root -p ${PORT} ${HOSTNAME}"
     CMD="${SSH} -n -l ${USER} -p ${PORT} ${HOSTNAME}"

     MSG=$BBTMP/${HOSTNAME}.${COLUMN}.out

     echo "client $HOSTNAME.linux linux"  >  $MSG

     SSHCMD="ls vmstat.sh"
     VMCHK=`/usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" 2>&1 | grep -c 'No such'`
     if [ ${VMCHK} -eq 1 ] ; then
        $SCP $XYMONHOME/ext/pi/vmstatpi.sh pi@${HOSTNAME}:vmstat.sh
        $SSHCMD="chmod 755 vmstat.sh"
        /usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" > /dev/null 2>&1
     fi
     SSHCMD="ls pitemp.sh"
     TEMPCHK=`/usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" 2>&1 | grep -c 'No such'`
     if [ ${TEMPCHK} -eq 1 ] ; then
        $SCP $XYMONHOME/ext/pi/pitemp.sh pi@${HOSTNAME}:pitemp.sh
        $SSHCMD="chmod 755 pitemp.sh"
        /usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" > /dev/null 2>&1
     fi

     SSHCMD="echo [date]"
     SSHCMD="${SSHCMD} ;  /bin/date 2>&1"
     SSHCMD="${SSHCMD} ; echo [uname] "
     SSHCMD="${SSHCMD} ;  /bin/uname -rsmn 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [osversion] "
     SSHCMD="${SSHCMD} ;  /usr/bin/lsb_release -r -i -s | xargs echo "
     SSHCMD="${SSHCMD} ;  echo [uptime] "
     SSHCMD="${SSHCMD} ;  /usr/bin/uptime 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [df] "
     SSHCMD="${SSHCMD} ;  /bin/df | egrep -v 'tmpfs|log2ram' "
     SSHCMD="${SSHCMD} ;  echo [inode] "
     SSHCMD="${SSHCMD} ;  /bin/df -i | egrep -v 'tmpfs|log2ram' "
     SSHCMD="${SSHCMD} ;  echo [mount] "
     SSHCMD="${SSHCMD} ;  /bin/mount "
     SSHCMD="${SSHCMD} ;  echo [free] "
     SSHCMD="${SSHCMD} ;  /usr/bin/free "
     SSHCMD="${SSHCMD} ;  echo [ifconfig] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig "
     SSHCMD="${SSHCMD} ;  echo [route] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -rn "
     SSHCMD="${SSHCMD} ;  echo [netstat] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -s "
     SSHCMD="${SSHCMD} ;  echo [ports] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -antuW "
     SSHCMD="${SSHCMD} ;  echo [ifstat] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig 2>&1"
     SSHCMD="${SSHCMD} ;  echo [top] "
     SSHCMD="${SSHCMD} ;  top -b -n 1 "
     SSHCMD="${SSHCMD} ;  echo '' "
     SSHCMD="${SSHCMD} ;  echo [nproc] "
     SSHCMD="${SSHCMD} ;  nproc --all 2>/dev/null "
     SSHCMD="${SSHCMD} ;  ps -Aww f -o pid,ppid,user,start,state,pri,pcpu,time:12,pmem,rsz:10,vsz:10,cmd "
     SSHCMD="${SSHCMD} ;  echo [msgs:/var/log/messages] "
     SSHCMD="${SSHCMD} ;  dmesg | tail "
     SSHCMD="${SSHCMD} ;  echo [logfile:/var/log/messages] "
     SSHCMD="${SSHCMD} ;  echo type:100000 \(file\) "
     SSHCMD="${SSHCMD} ;  echo mode:600 \(-rw-------\) "
     SSHCMD="${SSHCMD} ;  echo linkcount:1 "
     SSHCMD="${SSHCMD} ;  echo owner:0 \(root\) "
     SSHCMD="${SSHCMD} ;  echo group:0 \(root\) "
     SSHCMD="${SSHCMD} ;  echo -n size:"
     SSHCMD="${SSHCMD} ; ls -al /var/log/messages | awk '{printf \$5}' "
     SSHCMD="${SSHCMD} ;  echo "
     SSHCMD="${SSHCMD} ;  /bin/date -r /var/log/messages +'mtime:%s (%Y/%m/%d-%T)' "
     SSHCMD="${SSHCMD} ;  echo [clientversion] "
     SSHCMD="${SSHCMD} ;  echo [clock] "
     SSHCMD="${SSHCMD} ;  /bin/date +'epoch: %s.000000%nlocal: %F %T %Z'"
     SSHCMD="${SSHCMD} ;  /bin/date -u +'UTC: %F %T %Z'"
     SSHCMD="${SSHCMD} ;  ./vmstat.sh "

     /usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" >> $MSG 2>&1

     $BB $BBDISP "@" < $MSG >$LOGFETCHCFG.tmp
     /bin/rm -f $MSG

# Get temp..
     COL=pitemp
     MSG=$BBTMP/${HOSTNAME}.${COL}.out
     SSHCMD="./pitemp.sh"
     /usr/local/bin/hatimerun -k 9 -t 10 ${CMD} "${SSHCMD}" > $BBTMP/${HOSTNAME}.${COL}.raw
     CPU=`egrep "^CPU" $BBTMP/${HOSTNAME}.${COL}.raw | cut -d' ' -f3 | cut -d'.' -f1`
     GPU=`egrep "^GPU" $BBTMP/${HOSTNAME}.${COL}.raw | cut -d' ' -f3 | cut -d'.' -f1`

     RED_PIC="&red"
     YELLOW_PIC="&yellow"
     GREEN_PIC="&green"

     echo >> ${MSG}

     COLOR="green"
     if [ ${CPU} -ge 77 ] ; then
        echo "${RED_PIC} CPU is hot" >> ${MSG}
        COLOR="red"
     elif [ ${CPU} -ge 67 ] ; then
        echo "${YELLOW_PIC} CPU is getting warm" >> ${MSG}
        COLOR="yellow"
     fi
     if [ ${GPU} -ge 77 ] ; then
        echo "${RED_PIC} GPU is hot" >> ${MSG}
        COLOR="red"
     elif [ ${GPU} -ge 67 ] ; then
        echo "${YELLOW_PIC} GPU is getting warm" >> ${MSG}
        COLOR="yellow"
     fi

     cat $BBTMP/${HOSTNAME}.${COL}.raw >> ${MSG}
     
     $BB $BBDISP "status $HOSTNAME.$COL $COLOR `/bin/date` `/bin/cat $MSG`"
     /bin/rm -f $MSG $BBTMP/${HOSTNAME}.${COL}.raw

done

exit 0
