source components/common.sh

CHECK_ROOT

PRINT "Setup YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
CHECK_STAT $?


PRINT "Install Erlang"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm install rabbitmq-server -y &>>${LOG}
CHECK_STAT $?

PRINT "Start RabbitMQ Service"
systemctl enable rabbitmq-server && systemctl start rabbitmq-server &>>${LOG}
CHECK_STAT $?

PRINT "Create a RabbitMQ User"
rabbitmqctl add_user roboshop ${RABBITMQ_USER_PASSWORD} &>>${LOG}
CHECK_STAT $?

PRINT "RabbitMQ User Tags"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
CHECK_STAT $?