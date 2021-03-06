source components/common.sh

CHECK_ROOT


yum install golang -y

useradd roboshop

cd /home/roboshop

curl -L -s -o /tmp/dispatch.zip https://github.com/roboshop-devops-project/dispatch/archive/refs/heads/main.zip
unzip -o /tmp/dispatch.zip
mv dispatch-main dispatch
cd dispatch
go mod init dispatch
go get
go build

sed -i -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/' /home/roboshop/dispatch/systemd.service

mv /home/roboshop/dispatch/systemd.service /etc/systemd/system/dispatch.service
systemctl daemon-reload
systemctl enable dispatch
systemctl restart dispatch