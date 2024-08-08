#!/bin/sh
# Script directory
SCRIPT_DIR="$(cd "$( dirname "$0" )" >/dev/null && pwd)"

# Load in logging library
. "${SCRIPT_DIR}/log.sh"

# Parse command line arguments
while [ $# -gt 0 ]; do
    case $1 in
        --topics)
            KAFKA_TOPIC_LIST="$2"
            shift
            shift
            ;;
        *)
            error "Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Check that the arguments were passed correctly
if [ -z "$KAFKA_TOPIC_LIST" ]; then
    warn "Usage: $0 --topics foobar,1,test,3"
    exit 1
fi

if [ -n "$KAFKA_TOPIC_LIST" ]; then
    IFS=',' read -r -a TOPICS <<-EOF
        $KAFKA_TOPIC_LIST
EOF

    DOCKER_COMMAND="docker exec kafka sh -c \""

    i=0
    while [ $i -lt ${#TOPICS[@]} ]; do
        topic=${TOPICS[i]}
        partitions=${TOPICS[i+1]}
        DOCKER_COMMAND="$DOCKER_COMMAND kafka-topics.sh --create --bootstrap-server localhost:9092 --topic $topic --partitions $partitions;"
        i=$((i + 2))
    done
    DOCKER_COMMAND="$DOCKER_COMMAND\" "
    info "Attempting to create kafka topics ..."
    eval "$DOCKER_COMMAND"
else
    info "No kafka topics to create."
fi
