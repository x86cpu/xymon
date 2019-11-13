#!/bin/sh


#  https://arris.secure.force.com/consumers/articles/General_FAQs/SB8200-Cable-Signal-Levels/

##XYMONHOME=/home/xymon/server/
##BBTMP=/home/xymon/server/tmp

SPEED=$XYMONHOME/ext/speedtest
COLUMN=speed
$BBHOME/bin/bbhostgrep --no-down=ssh --noextras ${COLUMN} |
while read L ; do
   set $L
   LINE=$L
   IP="$1"
   HOSTNAME="$2"

   FILE="$BBTMP/speed.out"
   SEND="$BBTMP/speed.send"

#
# Get the status
${SPEED} -u bps --selection-details > ${FILE}.raw
echo  > ${FILE}
cat ${FILE}.raw >> ${FILE}

DOWN=`grep Download ${FILE} | sed -e's/  */ /g' | cut -d' ' -f3`
UP=`grep Upload ${FILE} | sed -e's/  */ /g' | cut -d' ' -f3`
PING=`grep Latency ${FILE} | sed -e's/  */ /g' | cut -d' ' -f3`

DMBS=`echo "scale=2; ${DOWN} / 1024 / 1024" | bc`
UMBS=`echo "scale=2; ${UP} / 1024 / 1024" | bc`
sed -i -e "s/${DOWN} bps/${DMBS} Mbps/" -e "s/${UP} bps/${UMBS} Mbps/" ${FILE}

COLOR="green"

echo "SPEED: UP DOWN PING" > ${SEND}
echo "SPEEDUP: ${UP}" >> ${SEND}
echo "SPEEDDOWN: ${DOWN}" >> ${SEND}
echo "SPEEDPING: ${PING}" >> ${SEND}

D=`echo "${DMBS}" | cut -d'.' -f1`
U=`echo "${UMBS}" | cut -d'.' -f1`
L=`echo "${PING}" | cut -d'.' -f1`

if [ ${D} -lt 50 ] ; then
   sed -i -e "s/Download:/\&red Download:/" ${FILE}
elif [ ${D} -lt 100 ] ; then
   sed -i -e "s/Download:/\&yellow Download:/" ${FILE}
else
   sed -i -e "s/Download:/\&green Download:/" ${FILE}
fi

if [ ${U} -lt 5 ] ; then
   sed -i -e "s/Upload:/\&red Upload:/" ${FILE}
elif [ ${U} -lt 10 ] ; then
   sed -i -e "s/Upload:/\&yellow Upload:/" ${FILE}
else
   sed -i -e "s/Upload:/\&green Upload:/" ${FILE}
fi

if [ ${L} -gt 100 ] ; then
   sed -i -e "s/Latency:/\&red Latency:/" ${FILE}
elif [ ${L} -gt 50 ] ; then
   sed -i -e "s/Latency:/\&yellow Latency:/" ${FILE}
else
   sed -i -e "s/Latency:/\&green Latency:/" ${FILE}
fi

COLOR="green"
if [ `grep -c red ${FILE}` -ge 1 ] ;  then
   COLOR="red"
elif [ `grep -c yellow ${FILE}` -ge 1 ] ;  then
   COLOR="yellow"
fi

#echo "COLOR=$COLOR"

$BB $BBDISP "data $HOSTNAME.$COLUMN

`$CAT $SEND`
"

$BB $BBDISP "status+30m $HOSTNAME.$COLUMN $COLOR `/bin/date` `/bin/cat $FILE`"
#/bin/rm -f $FILE ${FILE}.raw ${SEND}

done
