CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo You are not a root user
      echo -e "\e[33mYou should run this script as a root user or with sudo\e[m"
      exit 1
  fi
}

CHECK_STAT() {
echo "-----------------------------"
if [ $1 -ne 0 ]; then
  echo -e "\e[31mFAILED\e[0m"
  echo -e "\n Check log file - ${LOG} for errors"
  exit 2
else
  echo -e "\e[32mSUCCESS\e[0m"
fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

PRINT() {
  echo "---------------$1-------------" >>${LOG}
  echo "$1"
}





NODEJS()
{
  CHECK_ROOT

  PRINT "Setting Up NodeJS YUM REPO"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Installing NodeJS"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Creating Application User"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${LOG}
  fi
  CHECK_STAT $?

  PRINT "Downloading ${COMPONENT} Content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
  CHECK_STAT $?

  cd /home/roboshop

  PRINT "Remove Old Content"
  rm -rf ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} Content"
  unzip -o /tmp/${COMPONENT}.zip &>>${LOG}
  CHECK_STAT $?

  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install NodeJS Dependencies"
  npm install &>>${LOG}
  CHECK_STAT $?

  PRINT "Update SystemD Configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Setup Systemd Service"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload
  CHECK_STAT $?



  PRINT "Start Cart Service"
  systemctl enable ${COMPONENT}&>>${LOG} && systemctl restart ${COMPONENT} &>>${LOG}
  CHECK_STAT $?
}





NGINX() {
  CHECK_ROOT
  PRINT "Installing NGINX"
  yum install nginx -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Download ${COMPONENT} Content"
  curl -s -L -o /tmp/{COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
  CHECK_STAT $?

  PRINT "Clean OLD Content"
  cd /usr/share/nginx/html
  rm -rf * &>>${LOG}
  CHECK_STAT $?


  PRINT "Extract ${COMPONENT} Content"
  unzip -o /tmp/${COMPONENT}.zip
  CHECK_STAT $?

  PRINT "Organize ${COMPONENT} Content"
  mv ${COMPONENT}-main/* . && mv static/* . && rm -rf ${COMPONENT}-main README.md &>>${LOG} && mv localhost.conf /etc/nginx/default.d/roboshop.conf
  CHECK_STAT $?

  PRINT "Update ${COMPONENT} Content"
  sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/user/ s/localhost/user.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
  CHECK_STAT $?

  PRINT "Start Nginx Service"
  systemctl enable nginx &>>${LOG} && systemctl restart nginx &>>${LOG}
  CHECK_STAT $?
}