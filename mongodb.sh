#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGFOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MONGODB SERVER"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable mongo"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "start mongo"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarted MongoDB"


