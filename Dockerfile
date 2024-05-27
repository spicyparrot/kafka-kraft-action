FROM alpine:3.20

ARG KAFKA_VERSION
ENV KAFKA_VERSION=${KAFKA_VERSION}
ARG KAFKA_ADVERTISED_LISTENERS
ENV ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}

#ENV KAFKA_VERSION=3.6.1
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_LOGS=/kafka_logs/
ENV PATH=${PATH}:${KAFKA_HOME}/bin
ARG KAFKA_ADVERTISED_LISTENERS
ENV ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}

LABEL name="kafka" version=${KAFKA_VERSION}

# Install bash
RUN apk update \
 && apk add openssl \
 && apk add bash \
 && apk add openjdk11 

# Create a non-root user, setting id to >=10000 to avoid clashing and creating a directory structure
RUN adduser -D -u 10000 -h /home/kafka-user -s /bin/sh kafka-user

# Download Kafka + Scala Versions
RUN wget -O /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
 && rm -rf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# Create a directory for init scripts and kafka logs
RUN mkdir -p  /opt/kafka/scripts ${KAFKA_LOGS}

# Copy kafka-kraft start script
COPY ./scripts/entrypoint.sh /opt/kafka/scripts

# Set ownership of directories and files to kafka-user
RUN chown -R kafka-user:kafka-user /opt/kafka /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_LOGS}

# Set the container to run as non-root user kafka-user by default
USER kafka-user

# Make scripts executable
RUN ["chmod", "+x", "/opt/kafka/scripts/entrypoint.sh"]

# Change working dir to init scripts directory
WORKDIR /opt/kafka/scripts

# Execute init script
ENTRYPOINT [ "./entrypoint.sh" ]