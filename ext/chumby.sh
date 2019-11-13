#!/bin/sh

COLUMN=chumby
SSH=/usr/bin/ssh 

$BBHOME/bin/bbhostgrep --no-down=ssh --noextras ${COLUMN} |
while read L ; do
     set $L
     LINE=$L
     IP="$1"
     HOSTNAME="$2"
     PORT=`echo ${LINE} | tr ' ' '\n' | egrep "^${COLUMN}:" | awk -F':' '{printf $2}'`
     PORT=22

#     CMD="${SSH} -n -l root -p ${PORT} ${HOSTNAME}"
     CMD="${SSH} -n -l chumby -p ${PORT} ${HOSTNAME}"

     MSG=$BBTMP/${HOSTNAME}.MSG.out
     MSG=/tmp/${HOSTNAME}.MSG.out

     echo "client $HOSTNAME.linux linux"  >  $MSG

     SSHCMD="echo [date]"
     SSHCMD="${SSHCMD} ;  /bin/date 2>&1"
     SSHCMD="${SSHCMD} ; echo [uname] "
     SSHCMD="${SSHCMD} ;  /bin/uname -rsmn 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [osversion] "
     SSHCMD="${SSHCMD} ;  cat /etc/version 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [uptime] "
     SSHCMD="${SSHCMD} ;  /usr/bin/uptime 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [df] "
     SSHCMD="${SSHCMD} ;  /bin/df -k "
     SSHCMD="${SSHCMD} ;  echo [inode] "
     SSHCMD="${SSHCMD} ;  /bin/df -i "
     SSHCMD="${SSHCMD} ;  echo [mount] "
     SSHCMD="${SSHCMD} ;  /bin/mount "
     SSHCMD="${SSHCMD} ;  echo [free] "
     if [ "${HOSTNAME}" = "therock" ] ; then
        SSHCMD="${SSHCMD} ;  /usr/bin/free "
     else
        SSHCMD="${SSHCMD} ;  cat /proc/meminfo 2>&1 | head -2 "
     fi	
     SSHCMD="${SSHCMD} ;  echo [ifconfig] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig "
     SSHCMD="${SSHCMD} ;  echo [route] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -rn "
     SSHCMD="${SSHCMD} ;  echo [ports] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -antuW "
     SSHCMD="${SSHCMD} ;  echo [ifstat] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig 2>&1"
     SSHCMD="${SSHCMD} ;  echo [ps] "
     SSHCMD="${SSHCMD} ;  /bin/ps 2>&1 "
#     SSHCMD="${SSHCMD} ;  echo [msgs:/var/log/messages] "
#     SSHCMD="${SSHCMD} ;  dmesg | tail "
#     SSHCMD="${SSHCMD} ;  echo [logfile:/var/log/messages] "
#     SSHCMD="${SSHCMD} ;  echo type:100000 \(file\) "
#     SSHCMD="${SSHCMD} ;  echo mode:600 \(-rw-------\) "
#     SSHCMD="${SSHCMD} ;  echo linkcount:1 "
#     SSHCMD="${SSHCMD} ;  echo owner:0 \(root\) "
#     SSHCMD="${SSHCMD} ;  echo group:0 \(root\) "
#     SSHCMD="${SSHCMD} ;  echo -n size:"
#     SSHCMD="${SSHCMD} ; ls -al /var/log/messages | awk '{printf \$5}' "
#     SSHCMD="${SSHCMD} ;  echo "
#     SSHCMD="${SSHCMD} ;  /bin/date -r /var/log/messages +'mtime:%s (%Y/%m/%d-%T)' "
     SSHCMD="${SSHCMD} ;  echo [clientversion] "
     SSHCMD="${SSHCMD} ;  echo [clock] "
     SSHCMD="${SSHCMD} ;  /bin/date +'epoch: %s.000000%nlocal: %F %T %Z'"
     SSHCMD="${SSHCMD} ;  /bin/date -u +'UTC: %F %T %Z'"

     /usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" >> $MSG 2>&1

     $BB $BBDISP "@" < $MSG >$LOGFETCHCFG.tmp
     /bin/rm -f $MSG

done

exit 0
