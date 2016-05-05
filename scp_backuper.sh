#!/bin/bash

#CONFIG_FILE="${HOME}/scp-backuper/scp_backuper.conf"
CONFIG_FILE="/etc/scp_backuper/scp_backuper.conf"
USER_NAME=:
IP=:
PORT=:
KEY=:
BACKUP_DIR=: # backup先
BACKUP_TARGET=: # backup元
#DATE_FILE="${HOME}/.scp_backuper"
DATE_FILE="/etc/scp_backuper/.scp_backuper"

for line in `cat ${CONFIG_FILE}`; do
        config_file+=($line) 
done

for i in `seq 0 ${#config_file[*]}`; do
        case ${config_file[$i]} in
                "User" ) USER_NAME=${config_file[$i + 1]};;
                "Ip" ) IP=${config_file[$i + 1]};;
                "Port" ) PORT=${config_file[$i + 1]};;
                "Key" ) KEY=${config_file[$i + 1]};;
                "BackupDir" ) BACKUP_DIR=${config_file[$i + 1]};;
                "BackupTarget" ) BACKUP_TARGET=${config_file[$i + 1]};;
        esac
done

#echo "USER_NAME = ${USER_NAME}"
#echo "IP = ${IP}"
#echo "PORT = ${PORT}"
#echo "KEY = ${KEY}"
#echo "BACKUP_DIR = ${BACKUP_DIR}"
#echo "BACKUP_TARGET = ${BACKUP_TARGET}"
#echo "DATE_FILE = ${DATE_FILE}"

func () {
        TARGET_FILES=""
        fileArray=()
        dirArray=()
        for filePath in ${1}*; do
                if [ -f $filePath ]; then
                        fileArray+=("$filePath")
                fi
        done
        #echo "------File----"
        for i in ${fileArray[@]}; do
                if [ $i -nt ${DATE_FILE} ]; then
                        #echo "${i} new"
                        TARGET_FILES="${TARGET_FILES} $i"
                fi
        done
        #echo "TARGET_FILES : ${TARGET_FILES}"
        if [ "$TARGET_FILES" != "" ]; then
                f=`scp -r -i ${KEY} -P ${PORT} ${TARGET_FILES} ${USER_NAME}@${IP}:${BACKUP_DIR}/$2`
                echo $f
        fi
        #echo "------Dir-----"
        for i in `ls ${1} -F | grep /`; do
                dirArray+=("$i")
        done
        for i in ${dirArray[@]}; do
                if [ "$1$i" -nt ${DATE_FILE} ]; then
                        #echo $i
                        func "$1$i" $i
                fi
        done
}

save_date=`date +%Y/%m/%d`
save_date="${save_date} `date +%H:%M`"

if [ -e $DATE_FILE ]; then
        func "${BACKUP_TARGET}/" "./"
        echo $save_date >${DATE_FILE}
else 
        f=`scp -r -i ${KEY} -P ${PORT} ${BACKUP_TARGET}/* ${USER_NAME}@${IP}:${BACKUP_DIR}`
        echo $f
        echo $save_date >${DATE_FILE}
fi











