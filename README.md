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
      uses: spicyparrot/kafka-kraft-action@v1.1.0
      with:
        kafka-version: "3.7.0"
        kafka-topics: "example,1"

    # kafka_runner_address env var created by the above step
    - name: 🧪 Run Unit Tests
      uses: ./.github/actions/test
      env:
        KAFKA_BOOTSTRAP_SERVERS: ${{ env.kafka_runner_address }}:9093
  ```

Ensure your Kafka bootstrap server references `$kafka_runner_address:9093` or `localhost:9092`.

👆 In the above snippet, the unit tests action uses the environment variable `KAFKA_BOOTSTRAP_SERVERS` when instantiating a kafka consumer / producer. For e.g. 

```python
producer_conf = {
        'bootstrap.servers': os.environ['KAFKA_BOOTSTRAP_SERVERS']
    }
producer = Producer(producer_conf)
```

We override that env var with the `kafka_runner_address` env var created by the *spicyparrot/kafka-kraft-action*.

### Inputs

- **`kafka-version`**
  - **Default:** `"3.7.0"`
  - **Description:** Version of Kafka to use
  - **Required:** *False*

- **`kafka-topics`**
  - **Default:** `""` 
  - **Description:** Comma-separated list of topics/partitions to create (e.g., `foo,1,bar,1,example1`)
  - **Required:** *False*

⚠️ **Important:** Intended for integration testing purposes.

Happy testing! 🎉🐳🔒
