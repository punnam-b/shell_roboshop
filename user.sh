#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGFOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST="mongodb.dhruvanakshatra.in"
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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling node js Default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $?  "Enable nodejs"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NODE JS"

#creating system user
id roboshop &>>$LOGS_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "create system user"
 else
        echo -e "Roboshop USER Already Existing.... $Y SKIPPING $N "
fi

mkdir  -p /app 
VALIDATE $? "create directory app"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "Download user code"

cd /app 
VALIDATE $? "Move to directory app"

rm -rf /app/*
VALIDATE $? "Removing Existing Code"

unzip /tmp/user.zip &>>LOGFILENAME
VALIDATE $? "Unzip user"

npm install &>>LOGFILENAME
VALIDATE $? "npm install"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>>LOGFILENAME
systemctl enable user &>>LOGFILENAME
systemctl start user &>>LOGFILENAME
VALIDATE $? "Enable & START user"

