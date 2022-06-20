USER_ID=${id -u}

if [ $USER_ID -ne 0 ]; then
  echo You are not a root user
  echo You can run this script as a root user or with sudo
  exit 1
fi

curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo

yum install -y mongodb-org

systemctl enable mongod

systemctl start mongod

systemctl restart mongod

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"

cd /tmp

unzip -o mongodb.zip

cd mongodb-main

mongo < catalogue.js

mongo < users.js