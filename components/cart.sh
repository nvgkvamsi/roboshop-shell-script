source components/common.sh

CHECK_ROOT


PRINT " Setting Up NodeJS YUM REPO"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT " Installing NodeJS"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Creating Application User"
useradd roboshop &>>${LOG}
CHECK_STAT $?

PRINT "Downloading Cart Content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>${LOG}
CHECK_STAT $?


cd /home/roboshop

PRINT "Extract Cart Content"
unzip -o /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJS Dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update SystemD Configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup Systemd Service"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload
systemctl enable cart

PRINT "Start Cart Service"
systemctl restart cart &>>${LOG}
CHECK_STAT $?

}