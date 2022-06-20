curl -sL https://rpm.nodesource.com/setup_lts.x | bash

yum install nodejs -y

useradd roboshop

curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip"

cd /home/roboshop

unzip /tmp/user.zip

mv user-main user

cd /home/roboshop/user

npm install

sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' /home/roboshop/user/systemd.service -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/user/systemd.service

mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service

systemctl daemon-reload

systemctl restart user

systemctl enable user