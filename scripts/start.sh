#!/bin/bash

# Constants
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd)"

# Load in logging library
. "${SCRIPT_DIR}/log.sh"

# Extract kafka version from cmd line args
while [[ $# -gt 0 ]];do
    case $1 in
        --version)
            VERSION="$2"
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
if [[ -z $VERSION ]]; then
    warn "Usage: $0 --version 3.6.1"
    warn "Cant find a kafka version to use"
    exit 1
fi


# Detect operating system
OS=$(uname -s)

# Set private IP based on the operating system
if [[ $OS == "Linux" ]]; then
    PRIVATE_IP=$(hostname -I | awk '{print $1}')
elif [[ $OS == "Darwin" ]]; then
    PRIVATE_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}')
else
    error "Unsupported operating system: $OS"
    exit 1
fi

# Check that the private IP address was detected
if [[ -z $PRIVATE_IP ]]; then
    error "Failed to detect the private IP address."
    exit 1
fi

# Log the detected IP address
info "Detected Private IP Address: $PRIVATE_IP"
sleep 3

# Export detected IP as a global variable
export ADVERTISED_HOSTNAME=$PRIVATE_IP
# Export kafka version
export KAFKA_VERSION=$VERSION

info "Detected Kafka Version: $KAFKA_VERSION"

# Log message before bringing up Kafka environment
info "Bringing up Kafka environment"

# Use envsubst to replace environment variables in docker-compose.yml and bring up Docker containers
envsubst < docker-compose.yml | docker-compose up -d
sleep 10 

# Log information about connecting to Kafka
info "Please connect to the following IP_ADDRESS:PORT to access Kafka"

# List IP/Port needed to connect to Kafka ports by inspecting Docker container logs
docker logs "$(docker ps --format '{{.Names}}' | grep 'kafka' | grep -v 'kafka-ui')" | grep 'advertised.listeners'

# Save the Kafka Address to a github env var so its reusable in other steps
echo "kafka_runner_address=$PRIVATE_IP" >> $GITHUB_ENV