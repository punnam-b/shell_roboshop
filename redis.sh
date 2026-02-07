#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGFOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST="redis.dhruvanakshatra.in"
SCRIPT_DIR=$PWD
echo " working directory '$SCRIPT_DIR'"

if [ $USERID -ne 0 ]; then
    echo  -e "$R .pls run with root user $N"  | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGFOLDER

VALIDATE (){
if [ $1 -ne 0 ]; then
    echo -e "$2....$R FAILED $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$2  ....$G SUCCESS $N" | tee -a $LOGS_FILE
fi

}

dnf module disable redis -y &>>LOGFILENAME
VALIDATE $? "Disabling redis Default version"

dnf module enable redis:7 -y &>>LOGFILENAME
VALIDATE $? "Enable redis Default version"

dnf install redis -y    &>>LOGFILENAME
VALIDATE $? "Install redis Default version"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "updated the parameters"

systemctl enable redis &>>LOGFILENAME
VALIDATE $? "enable redis Default version"

systemctl start redis &>>LOGFILENAME
VALIDATE $? "start redis Default version"