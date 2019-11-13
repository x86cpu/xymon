#!/bin/sh


#  https://arris.secure.force.com/consumers/articles/General_FAQs/SB8200-Cable-Signal-Levels/

COLUMN=signal
$BBHOME/bin/bbhostgrep --no-down=ssh --noextras ${COLUMN} |

while read L ; do
   set $L
   LINE=$L
   IP="$1"
   HOSTNAME="$2"

   FILE="/tmp/cable.status"
   SEND="/tmp/cable.send"

   RED_PIC="&red"
   YELLOW_PIC="&yellow"
   GREEN_PIC="&green"


#
# Get the status
lynx -dump --width=132 "http://${IP}/cmconnectionstatus.html" > ${FILE}.raw
echo  > ${FILE}
cat ${FILE}.raw >> ${FILE}


# Get  DOWN and UP

grep  'dB ' ${FILE} | sed -e's/Not Locked/Not_Locked/' > /tmp/DOWN
grep 'dBmV' ${FILE} | grep -v 'dB ' > /tmp/UP

DOWN=`cat /tmp/DOWN | awk '{printf $1" "}'`
UP=`cat /tmp/UP | awk '{printf $2" "}'`

COLOR="green"

echo "DOWN: ${DOWN}" > ${SEND}
while read CHANNEL STAT QAM FREQ X POWER X SNR X CORR UNCORR ; do
   echo "DOWN${CHANNEL}power: ${POWER}" >> ${SEND}
   echo "DOWN${CHANNEL}snr: ${SNR}" >> ${SEND}
   echo "DOWN${CHANNEL}corrected: ${CORR}" >> ${SEND}
   echo "DOWN${CHANNEL}uncorrectables: ${UNCORR}" >> ${SEND}
   P=`echo "${POWER}" | cut -d'.' -f1`
   S=`echo "${SNR}" | cut -d'.' -f1`
   if [ ${P} -gt 15 -o ${P} -lt -15 ] ; then
      sed -i -e"s/         ${CHANNEL}         L/         \&red ${CHANNEL}         L/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          L/          \&red ${CHANNEL}          L/" ${FILE}
      sed -i -e"s/         ${CHANNEL}         N/         \&red ${CHANNEL}         N/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          N/          \&red ${CHANNEL}          N/" ${FILE}
   elif [ ${P} -gt -6 -a ${S} -lt 30 ] ;  then
      sed -i -e"s/         ${CHANNEL}         L/         \&yellow ${CHANNEL}         L/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          L/          \&yellow ${CHANNEL}          L/" ${FILE}
      sed -i -e"s/         ${CHANNEL}         N/         \&yellow ${CHANNEL}         N/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          N/          \&yellow ${CHANNEL}          N/" ${FILE}
   elif [ ${P} -le -6 -a ${S} -lt 33 ] ;  then
      sed -i -e"s/         ${CHANNEL}         L/         \&yellow ${CHANNEL}         L/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          L/          \&yellow ${CHANNEL}          L/" ${FILE}
      sed -i -e"s/         ${CHANNEL}         N/         \&yellow ${CHANNEL}         N/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          N/          \&yellow ${CHANNEL}          N/" ${FILE}
   else
      sed -i -e"s/         ${CHANNEL}         L/         \&green ${CHANNEL}         L/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          L/          \&green ${CHANNEL}          L/" ${FILE}
      sed -i -e"s/         ${CHANNEL}         N/         \&green ${CHANNEL}         N/" ${FILE}
      sed -i -e"s/          ${CHANNEL}          N/          \&green ${CHANNEL}          N/" ${FILE}
   fi
done < /tmp/DOWN

echo "UP: ${UP}" >> ${SEND}

while read ID CHANNEL STATUS QAM FREQ X X X POWER X ; do
   echo "UP${CHANNEL}power: ${POWER}" >> ${SEND}
   P=`echo "${POWER}" | cut -d'.' -f1`
##   if [ ${P} -gt 51 -o ${P} -lt 45 ] ; then
   if [ ${P} -gt 51 -o ${P} -lt 35 ] ; then
      sed -i -e"s/         ${ID}       ${CHANNEL}       /        \&yellow ${ID}      ${CHANNEL}       /" ${FILE}
   else
      sed -i -e"s/         ${ID}       ${CHANNEL}       /        \&green ${ID}      ${CHANNEL}       /" ${FILE}
   fi
done < /tmp/UP


COLOR="green"
if [ `grep -c red ${FILE}` -ge 1 ] ;  then
   COLOR="red"
elif [ `grep -c yellow ${FILE}` -ge 1 ] ;  then
   COLOR="yellow"
fi

$BB $BBDISP "data $HOSTNAME.$COLUMN

`$CAT $SEND`
"

$BB $BBDISP "status $HOSTNAME.$COLUMN $COLOR `/bin/date` `/bin/cat $FILE`"
/bin/rm -f $FILE ${FILE}.raw ${SEND}

done
