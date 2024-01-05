#!/bin/bash
NODE_ID=0
LOGS_DIR=/kafka_logs
SECURITY_PROTOCOL_MAP="CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL"
LISTENERS="PLAINTEXT://:9092,EXTERNAL://:9093,CONTROLLER://:9094"
CONTROLLER_QUORUM_VOTERS="$NODE_ID@localhost:9094"

# Create a logs directory
mkdir -p $LOGS_DIR/$NODE_ID

sed -e "s+^node.id=.*+node.id=$NODE_ID+" \
-e "s+^controller.quorum.voters=.*+controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS+" \
-e "s+^listener.security.protocol.map=.*+listener.security.protocol.map=$SECURITY_PROTOCOL_MAP+" \
-e "s+^listeners=.*+listeners=$LISTENERS+" \
-e "s+^advertised.listeners=.*+advertised.listeners=$ADVERTISED_LISTENERS+" \
-e "s+^log.dirs=.*+log.dirs=$LOGS_DIR/$NODE_ID+" \
/opt/kafka/config/kraft/server.properties > server.properties.updated

mv server.properties.updated /opt/kafka/config/kraft/server.properties

CLUSTER_ID=$(kafka-storage.sh random-uuid)

kafka-storage.sh format -t $CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

exec kafka-server-start.sh /opt/kafka/config/kraft/server.properties