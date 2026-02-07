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



dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install MYSQL"

systemctl enable mysqld &>>$LOGS_FILE
VALIDATE $? "Enable sql user" 

systemctl start mysqld  &>>$LOGS_FILE
VALIDATE $? " START sql user"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Root password setup"

