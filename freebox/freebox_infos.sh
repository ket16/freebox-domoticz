#!/bin/bash
cd /home/pi/freebox

# Freebox Server Authentification
MY_APP_ID="Domoticz.app"
MY_APP_TOKEN="INSCRIRE_LE_TOKEN_ICI"

# Domoticz server
DOMOTICZ_SERVER="192.168.1.145:8080"
DOMOTICZ_USER="admin"
DOMOTICZ_PWD="password"

# Freebox Server idx
FREEBOX_FW_IDX="6"
FREEBOX_UPTIME_IDX="5"
FREEBOX_ATM_UP_IDX="65"
FREEBOX_ATM_DOWN_IDX="64"
FREEBOX_DISKSPACE_IDX="57"
FREEBOX_SERIAL_IDX="50"
FREEBOX_MODELE_IDX="51"
FREEBOX_TEMP_CPUB_IDX="52"
FREEBOX_REC_EN_COURS_IDX="61"
FREEBOX_EMIS_EN_COURS_IDX="60"
FREEBOX_BANDWIDTH_DOWN_IDX="63"
FREEBOX_BANDWIDTH_UP_IDX="62"


#
function show_time () {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"%20jours%20"$hour"%20heures%20"$min"%20mn%20"$sec"%20secs
}


# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL data
answer=$(call_freebox_api '/connection/xdsl')
#echo " answer : ${answer} "
#echo " "
# extract max upload xDSL rate
uptime=$(get_json_value_for_key "$answer" 'result.status.uptime')
uptimefreebox=$(show_time ${uptime})
echo "Uptime : ${uptimefreebox} "

atm_up_rate=$(get_json_value_for_key "$answer" 'result.up.maxrate')
atm_up_rate=$(awk "BEGIN {printf \"%.1f\",${atm_up_rate}/1000}")
#up_max_rate=$(echo "$up_max_rate%20Mb/s")
atm_down_rate=$(get_json_value_for_key "$answer" 'result.down.rate')
atm_down_rate=$(awk "BEGIN {printf \"%.1f\",${atm_down_rate}/1000}")
#down_max_rate=$(echo "$down_max_rate%20Mb/s")

echo "Rate ATM down xDSL rate: ${atm_down_rate} "
echo "Rate ATM up xDSL: ${down_max_rate} "


echo "************ CONNECTION ************"
answer=$(call_freebox_api '/connection')
debit_reception=$(get_json_value_for_key "$answer" 'result.rate_down')
debit_reception=$(awk "BEGIN {printf \"%.1f\",${debit_reception}/1000}")

debit_emission=$(get_json_value_for_key "$answer" 'result.rate_up')
debit_emission=$(awk "BEGIN {printf \"%.1f\",${debit_emission}/1000}")

bande_passante_maxi_reception=$(get_json_value_for_key "$answer" 'result.bandwidth_down')
bande_passante_maxi_reception=$(awk "BEGIN {printf \"%.1f\",${bande_passante_maxi_reception}/1000000}")

bande_passante_maxi_emission=$(get_json_value_for_key "$answer" 'result.bandwidth_up')
bande_passante_maxi_emission=$(awk "BEGIN {printf \"%.1f\",${bande_passante_maxi_emission}/1000000}")



answer=$(call_freebox_api '/system')
#echo " answer : ${answer} "
#uptimefreebox=$(get_json_value_for_key "$answer" 'result.uptime')
fwfreebox=$(get_json_value_for_key "$answer" 'result.firmware_version')
#echo "Uptime : ${uptimefreebox} "
echo "Firmware : ${fwfreebox} "

answer=$(call_freebox_api '/storage/disk')
answer=$(echo ${answer} | sed -e "s/\[//g" | sed -e "s/\]//g")
#echo " answer : ${answer} "
freediskspace=$(get_json_value_for_key "$answer" 'result.partitions.free_bytes')
freediskspace=$(echo $((${freediskspace}/1024/1024)))
freediskspace=$(awk "BEGIN {printf \"%.2f\",${freediskspace}/1024}")
#freediskspace=$(echo "${freediskspace}%20Go")
echo "Free space HD : ${freediskspace} "

num_serie=$(get_json_value_for_key "$answer" 'result.serial')
modele=$(get_json_value_for_key "$answer" 'result.model')

# Température CPUb: ne fonctionne pas
#temperature_cpub=$(get_json_value_for_key "$answer" 'result.temp_cpub')
#temperature_cpub=$(echo $(${temperature_cpub}))
#temperature_cpub=$(echo "${temperature_cpub}")
#echo "Temperature CPU B : ${temperature_cpub}"

#
#Envoi des valeurs vers les devices virtuels
# Send data to Domoticz
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_FW_IDX&nvalue=0&svalue=$fwfreebox"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_UPTIME_IDX&nvalue=0&svalue=$uptimefreebox"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_ATM_UP_IDX&nvalue=0&svalue=$atm_up_rate"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_ATM_DOWN_IDX&nvalue=0&svalue=$atm_down_rate"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_DISKSPACE_IDX&nvalue=0&svalue=$freediskspace"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_SERIAL_IDX&nvalue=0&svalue=$num_serie"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_MODELE_IDX&nvalue=0&svalue=$modele"
#curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_TEMP_CPUB_IDX&nvalue=0&svalue=$temperature_cpub"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_REC_EN_COURS_IDX&nvalue=0&svalue=$debit_reception"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_EMIS_EN_COURS_IDX&nvalue=0&svalue=$debit_emission"
curl --silent -s -i -H  "Accept: application/json"  "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_BANDWIDTH_UP_IDX&nvalue=0&svalue=$bande_passante_maxi_emission"
curl --silent -s -i -H "Accept: application/json" "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_BANDWIDTH_DOWN_IDX&nvalue=0&svalue=$bande_passante_maxi_reception"
