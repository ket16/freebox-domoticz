#!/bin/bash

# Ce batch interroge la Freebox et liste tous les compteurs disponibles (cette version n'est pas complète)

cd /home/pi/freebox
# Domoticz server
DOMOTICZ_SERVER="192.168.1.145:8080"

MY_APP_ID="Domoticz.app"
MY_APP_TOKEN="INSCRIRE_LE_TOKEN_ICI"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

echo "************ CONNECTION/XDSL ************"
answer=$(call_freebox_api '/connection/xdsl')
echo " answer : ${answer} "
echo " "

echo "************ SYSTEM ************"
answer=$(call_freebox_api '/system')
echo " answer : ${answer} "
echo " "

echo "************ STORAGE/DISK ************"
answer=$(call_freebox_api '/storage/disk')
answer=$(echo ${answer} | sed -e "s/\[//g" | sed -e "s/\]//g")
echo " answer : ${answer} "
echo " "

echo "************ VPN_CLIENT/STATUS ************"
answer=$(call_freebox_api '/vpn_client/status')
echo " answer : ${answer} "
echo " "

echo "************ DOWNLOAD/STATS ************"
answer=$(call_freebox_api '/downloads/stats')
echo " answer : ${answer} "
echo " "

echo "************ CONNECTION ************"
answer=$(call_freebox_api '/connection')
echo " answer : ${answer} "
echo " "
