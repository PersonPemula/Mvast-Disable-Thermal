#!/bin/sh
while [ -z "$(resetprop sys.boot_completed)" ]; do
  sleep 5
done
while true; do
  sleep 2
  thermal_active=$(resetprop | grep thermal | grep -e running -e restarting)
  if [ "$thermal_active" ]; then

if [ -e "/data/adb/modules/mvast-dt" ]; then
    find /sys -name mode | grep 'thermal_zone' | while IFS= read -r thermal_zone_status; do
        if [ "$(cat "$thermal_zone_status")" = 'enabled' ]; then
            echo 'disabled' > "$thermal_zone_status"
        fi
    done
    sleep 1
    find /sys -name enabled | grep 'msm_thermal' | while IFS= read -r msm_thermal_status; do
        if [ "$(cat $msm_thermal_status)" = 'Y' ]; then
            echo 'N' > "$msm_thermal_status"
        fi
        if [ "$(cat $msm_thermal_status)" = '1' ]; then
            echo '0' > "$msm_thermal_status"
        fi
    done
    stop logd
    sleep 1
    for thermal in $(resetprop | awk -F '[][]' '/thermal/ {print $2}'); do
        if [ "$(resetprop "$thermal")" = 'running' ] || [ "$(resetprop "$thermal")" = 'restarting' ]; then
            sleep 1
            stop "$(echo "$thermal" | sed 's/init.svc.//')"
        fi
        sleep 3
        if [ "$(resetprop "$thermal")" = 'running' ] || [ "$(resetprop "$thermal")" = 'restarting' ]; then
            resetprop -n "$thermal" stopped
        fi
    done
    sleep 1
    if [ $(resetprop sys.thermal.enable | grep -q 'true') ]; then
        resetprop -n sys.thermal.enable false
    fi
    sleep 1
    find /sys -name temp | grep 'thermal_zone' | while IFS= read -r thermal_zone_temp; do
        if [ -r "$thermal_zone_temp" ]; then
            chmod a-r "$thermal_zone_temp"
        fi
    done
else
    reboot
fi

    sleep 2
  else
    break
  fi
done
