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


dnf install python3 gcc python3-devel -y  &>>$LOGS_FILE
VALIDATE $? "cinstall python3 "

id roboshop &>>$LOGS_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "create system user"
 else
        echo -e "Roboshop USER Already Existing.... $Y SKIPPING $N "
fi

mkdir  -p /app 
VALIDATE $? "create directory app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
VALIDATE $? "Download catalogue code"


cd /app 
VALIDATE $? "Move to directory app"

rm -rf /app/*
VALIDATE $? "Removing Existing Code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Unzip Catalogue"


cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "PIP 2 insall"


systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "demon reload"

systemctl enable payment  &>>$LOGS_FILE
systemctl start payment &>>$LOGS_FILE
VALIDATE $? "enable payment and start"