#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGFOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MYSQL_HOST="mysql.dhruvanakshatra.in"
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo 
VALIDATE $? "coping repo mq server"


dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "install rabbit mq server"

systemctl enable rabbitmq-server  &>>$LOGS_FILE
systemctl start rabbitmq-server  &>>$LOGS_FILE
VALIDATE $? "enable and start rabbit mq server"


rabbitmqctl add_user roboshop roboshop123  &>>$LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$LOGS_FILE

VALIDATE $? "created user and give permissions"

