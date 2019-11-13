#!/bin/bash


GPU=`/usr/bin/vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'`
cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))

CPU="$cpuTemp1"."$cpuTempM"

echo "CPU : $CPU"
echo "GPU : $GPU"
