#!/bin/sh

COLUMN=ubnt
SSH=/usr/bin/ssh 

$BBHOME/bin/bbhostgrep --no-down=ssh --noextras ${COLUMN} |
while read L ; do
     set $L
     LINE=$L
     IP="$1"
     HOSTNAME="$2"
     PORT=22
     CMD="${SSH} -n -q -l admin -p ${PORT} ${HOSTNAME}"

     MSG=$BBTMP/${HOSTNAME}.MSG.out

     echo "client $HOSTNAME.linux linux"  >  $MSG

     SSHCMD="echo [date]"
     SSHCMD="${SSHCMD} ;  /bin/date 2>&1"
     SSHCMD="${SSHCMD} ; echo [uname] "
     SSHCMD="${SSHCMD} ;  /bin/uname -rsmn 2>&1 "
     SSHCMD="${SSHCMD} ;  echo [osversion] "
     SSHCMD="${SSHCMD} ;  cat /etc/version "
     SSHCMD="${SSHCMD} ;  echo [uptime] "
     SSHCMD="${SSHCMD} ;  /usr/bin/uptime 2>&1 "
##     SSHCMD="${SSHCMD} ;  echo [df] "
##     SSHCMD="${SSHCMD} ;  /bin/df 2>/dev/null | egrep -v 'tmpfs|aufs|none|unionfs' "
     SSHCMD="${SSHCMD} ;  echo [mount] "
     SSHCMD="${SSHCMD} ;  /bin/mount "
     SSHCMD="${SSHCMD} ;  echo [free] "
     SSHCMD="${SSHCMD} ;  /usr/bin/free "
     SSHCMD="${SSHCMD} ;  echo [ifconfig] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig "
     SSHCMD="${SSHCMD} ;  echo [route] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -rn "
     if [ "${HOSTMAME}" = "thewolf" ] ; then
        SSHCMD="${SSHCMD} ;  echo [netstat] "
        SSHCMD="${SSHCMD} ;  /bin/netstat -s "
     fi
     SSHCMD="${SSHCMD} ;  echo [ports] "
     SSHCMD="${SSHCMD} ;  /bin/netstat -antuW "
     SSHCMD="${SSHCMD} ;  echo [ifstat] "
     SSHCMD="${SSHCMD} ;  /sbin/ifconfig 2>&1"
     SSHCMD="${SSHCMD} ;  echo [nproc] "
     SSHCMD="${SSHCMD} ;  grep -c processor /proc/cpuinfo "
     SSHCMD="${SSHCMD} ;  echo [ps] "
     if [ "${HOSTMAME}" = "thewolf" ] ; then
        SSHCMD="${SSHCMD} ;  ps -Aww f -o pid,ppid,user,start,state,pri,pcpu,time:12,pmem,rsz:10,vsz:10,cmd "
     else
        SSHCMD="${SSHCMD} ;  /bin/ps 2>&1 "
     fi
     SSHCMD="${SSHCMD} ;  echo [msgs:/var/log/messages] "
     SSHCMD="${SSHCMD} ;  /usr/bin/tail -10 /var/log/messages "
     SSHCMD="${SSHCMD} ;  echo [logfile:/var/log/messages] "
     SSHCMD="${SSHCMD} ;  echo type:100000 \(file\) "
     SSHCMD="${SSHCMD} ;  echo mode:600 \(-rw-------\) "
     SSHCMD="${SSHCMD} ;  echo linkcount:1 "
     SSHCMD="${SSHCMD} ;  echo owner:0 \(admin\) "
     SSHCMD="${SSHCMD} ;  echo group:0 \(root\) "
     SSHCMD="${SSHCMD} ;  echo -n size:"
     SSHCMD="${SSHCMD} ; ls -al /var/log/messages | awk '{printf \$5}' "
     SSHCMD="${SSHCMD} ;  echo "
     SSHCMD="${SSHCMD} ;  /bin/date -r /var/log/messages +'mtime:%s (%Y/%m/%d-%T)' "
     SSHCMD="${SSHCMD} ;  echo [clientversion] "
     SSHCMD="${SSHCMD} ;  echo [clock] "
     SSHCMD="${SSHCMD} ;  /bin/date +'epoch: %s.000000%nlocal: %F %T %Z'"
     SSHCMD="${SSHCMD} ;  /bin/date -u +'UTC: %F %T %Z'"

     /usr/local/bin/hatimerun -k 9 -t 60 ${CMD} "${SSHCMD}" >> $MSG 2>&1


     $BB $BBDISP "@" < $MSG >$LOGFETCHCFG.tmp
     /bin/rm -f $MSG

done

exit 0
