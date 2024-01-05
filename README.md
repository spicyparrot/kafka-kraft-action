## 🚀 Kafka KRaft GitHub Action

### Overview

Automate Kafka KRaft broker creation with this GitHub Action. Build a lightweight container for seamless integration testing in GitHub pipelines. 🛠️

Specify the Kafka version for testing - **KRaft** is production-ready from version 3.3 onward. 🚦

Indicate topics and partitions with a comma-separated list argument, e.g., `foo,1,bar,2`.

Expose two listeners for client connections:
- First listener: `localhost:9092`. 🌐
- Second listener: `$kafka_runner_address:9093`, using an environment variable pointing to the runner's private IP. 🏃‍♂️

For optimal results, leverage the latter. See [this insightful post](https://rmoff.net/2018/08/02/kafka-listeners-explained/) for details.

### Features

- **Automated KRaft Broker Setup** 🏗️: Construct a container for integration testing effortlessly.
- **Flexible Kafka Version** 🔄: Specify the desired Kafka version for testing purposes.
- **Dynamic Topic Creation** 📊: Create topics and partitions by supplying a comma-separated list argument.
- **Listener Exposure** 🌐: Expose two listeners for client connections.

### Usage

Implement in your unit testing pipelines:

```yaml
name: "Unit Testing"

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Run Kafka KRaft Broker
      uses: your-username/your-repo@v1
      with:
        kafka-version: "3.6.1"
        kafka-topics: "example,1"

    - name: 🧪 Run Unit Tests
      uses: ./.github/actions/test
  ```

Ensure your Kafka bootstrap server references `$kafka_runner_address:9093` or `localhost:9092`.

### Inputs

- **`kafka-version`**
  - **Default:** `"3.6.1"`
  - **Description:** Version of Kafka to use
  - **Required:** *False* (Defaults to `3.6.1`)

- **`kafka-topics`**
  - **Default:** `""` 
  - **Description:** Comma-separated list of topics/partitions to create (e.g., `foo,1,bar,1,example1`)
  - **Required:** *False*

⚠️ **Important:** Intended for integration testing purposes.

Happy testing! 🎉🐳🔒
