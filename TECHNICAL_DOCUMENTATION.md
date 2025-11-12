# Technical Documentation - Files and Functions

This document provides a comprehensive explanation of all files, functions, and their purposes in the Click Streaming Data Pipeline project.

---

## 📁 Project Structure

```
Click-Streaming-Data-Pipeline/
├── api/                    # Flask API server
│   ├── pipeline/          # Pipeline processing module
│   ├── server.py          # Main Flask application
│   └── requirements.txt   # Python dependencies
├── demo-website/          # Interactive demo website
│   ├── index.html         # Frontend HTML/JS
│   └── start-demo.ps1     # Startup script
├── pyspark/               # Spark streaming jobs
│   └── apps/
│       └── spark_streaming.py
├── docker/                # Docker configurations
│   ├── spark/
│   └── kafka-connect/
├── generator/             # Event generator
│   └── generator.py
├── schemas/               # Avro schemas
├── connectors/            # Kafka Connect configs
├── scripts/               # Utility scripts
└── docker-compose.yaml    # Docker Compose configuration
```

---

## 🔧 API Server (`api/`)

### **1. `api/server.py` - Flask Application Server**

**Purpose:** Main entry point for the REST API that receives clickstream events.

#### **Functions:**

##### `setup()`
```python
def setup():
    """ Setup necessary parameters
    
    :return: port number
    """
```
- **Purpose:** Configures command-line arguments and logging
- **Parameters:** None (uses `argparse` to get port from command line)
- **Returns:** Port number (default: 60000)
- **What it does:**
  - Creates argument parser
  - Accepts optional port number argument
  - Sets up logging configuration
  - Returns the port number to use

##### `answer(result)`
```python
def answer(result):
    """ Helper method for creating a JSON answer
    
    :return: HTTP Response
    """
```
- **Purpose:** Creates standardized JSON HTTP responses
- **Parameters:** `result` (dict) - Data to return as JSON
- **Returns:** Flask Response object with JSON content
- **What it does:**
  - Converts dictionary to JSON string
  - Sets content type to `application/json`
  - Returns HTTP 200 status

##### `ping()` - Route Handler
```python
@app.route("/ping", methods=["GET"])
def ping():
    return answer({"status": "OK"})
```
- **Purpose:** Health check endpoint
- **Route:** `GET /ping`
- **Returns:** `{"status": "OK"}`
- **Use case:** Verify API server is running

##### `collect()` - Route Handler
```python
@app.route("/collect", methods=["POST"])
def collect():
    event = request.get_json()
    return answer(input.collect(event))
```
- **Purpose:** Receives clickstream events from clients
- **Route:** `POST /collect`
- **Parameters:** JSON array of events in request body
- **Returns:** Processing results with validation status
- **What it does:**
  - Receives JSON events from request
  - Calls `input.collect()` to process events
  - Returns processing results

#### **Key Components:**
- **Flask App:** `app = Flask(__name__)`
- **CORS:** `CORS(app)` - Enables Cross-Origin Resource Sharing for demo website
- **Server:** Runs on `0.0.0.0:60000` (accessible from all interfaces)

---

### **2. `api/pipeline/input.py` - Event Processing Pipeline**

**Purpose:** Validates events and sends them to Kafka.

#### **Global Variables:**
- `_kafka_producer`: Singleton Kafka producer instance
- `key_schema`: Avro schema for event keys (currently not used)
- `value_schema`: Avro schema for event values (currently not used)

#### **Functions:**

##### `get_kafka_producer()`
```python
def get_kafka_producer():
    """ Get or create Kafka producer """
```
- **Purpose:** Creates and returns a singleton Kafka producer
- **Returns:** `KafkaProducer` instance or `None` on error
- **What it does:**
  - Checks if producer already exists (singleton pattern)
  - Creates new producer if needed:
    - Connects to `localhost:9092`
    - Sets up JSON serializers
    - Configures API version and retries
  - Logs success or failure
  - Returns producer instance

##### `is_valid(data, schema=None)`
```python
def is_valid(data, schema=None):
    """ Simple validation - just check if data has required fields. """
```
- **Purpose:** Validates event structure
- **Parameters:**
  - `data` (dict): Event to validate
  - `schema` (optional): Schema for validation (currently unused)
- **Returns:** `True` if valid, `False` otherwise
- **Validation rules:**
  - Must be a dictionary
  - Must contain: `type`, `package_id`, `event`
- **What it does:**
  - Checks if data is a dictionary
  - Verifies required fields exist
  - Returns validation result

##### `collect(events)`
```python
def collect(events):
    correlation_id = str(uuid4())
    # ... processes events ...
```
- **Purpose:** Main event processing function
- **Parameters:** `events` (list) - Array of event dictionaries
- **Returns:** Dictionary with processing results
- **What it does:**
  1. **Generates correlation ID:** Unique identifier for this batch
  2. **Initializes counters:** `valid_count`, `invalid_count`
  3. **Processes each event:**
     - Validates event structure
     - If valid:
       - Gets Kafka producer
       - Sends event to Kafka topic `acme.clickstream.raw.events`
       - Waits for send confirmation
       - Logs success
     - If invalid:
       - Logs rejection
       - Increments invalid count
  4. **Returns results:**
     ```python
     {
         "status": "success",
         "correlation_id": "...",
         "processed_count": 5,
         "valid_count": 4,
         "invalid_count": 1,
         "elapsed_time": 0.003
     }
     ```

#### **Kafka Integration:**
- **Topic:** `acme.clickstream.raw.events`
- **Key:** Event ID (as string)
- **Value:** Event JSON (as bytes)
- **Bootstrap servers:** `localhost:9092`
- **Serialization:** JSON to UTF-8 bytes

---

## 🎨 Demo Website (`demo-website/`)

### **1. `demo-website/index.html` - Interactive E-Commerce Demo**

**Purpose:** Provides a user-friendly interface to generate clickstream events.

#### **Key Components:**

##### **HTML Structure:**
- **Header:** Title and description
- **Status Bar:** Shows event streaming status and counter
- **Left Panel:** Product grid with search
- **Right Panel:** Real-time event log (always visible)

##### **JavaScript Functions:**

##### `init()`
```javascript
function init() {
    renderProducts();
    sendEvent('click', '/home', null, null, 'https://google.com');
}
```
- **Purpose:** Initializes the page
- **What it does:**
  - Renders product grid
  - Sends initial "click" event for home page

##### `renderProducts()`
```javascript
function renderProducts() {
    const grid = document.getElementById('productsGrid');
    grid.innerHTML = products.map(product => `...`).join('');
}
```
- **Purpose:** Dynamically creates product cards
- **What it does:**
  - Maps product data to HTML
  - Creates product cards with:
    - Product image (emoji)
    - Product name and price
    - "View Details" button
    - "Buy Now" button

##### `sendEvent(type, page, query, product, referrer)`
```javascript
async function sendEvent(type, page, query, product, referrer) {
    // Creates event object
    // Sends to API
    // Updates UI
}
```
- **Purpose:** Sends clickstream events to API
- **Parameters:**
  - `type`: Event type ('click', 'view', 'purchase')
  - `page`: Page URL
  - `query`: Search query (if any)
  - `product`: Product ID (if any)
  - `referrer`: Referrer URL
- **What it does:**
  1. Gets product details if product ID provided
  2. Creates event object with:
     - Unique ID (timestamp)
     - Event type
     - Package ID (unique identifier)
     - Event details (user agent, IP, customer ID, timestamp, etc.)
     - Product name and price (if applicable)
  3. Sends POST request to `http://localhost:60000/collect`
  4. Updates event counter and log on success

##### `addEventLog(type, page, product, error)`
```javascript
function addEventLog(type, page, product, error = false) {
    // Creates event log entry
    // Adds to UI
    // Keeps only last 20 events
}
```
- **Purpose:** Displays events in the event log
- **Parameters:**
  - `type`: Event type
  - `page`: Page URL
  - `product`: Product ID
  - `error`: Boolean indicating if send failed
- **What it does:**
  - Creates event log entry with status icon
  - Adds timestamp
  - Inserts at top of log
  - Keeps only last 20 events

##### `handleSearch(event)`
```javascript
function handleSearch(event) {
    if (event.key === 'Enter' && event.target.value.trim()) {
        const query = event.target.value.trim();
        sendEvent('view', '/products', query, null, '/home');
    }
}
```
- **Purpose:** Handles search functionality
- **What it does:**
  - Listens for Enter key
  - Sends 'view' event with search query

##### `viewProduct(productId)`
```javascript
function viewProduct(productId) {
    const product = products.find(p => p.id === productId);
    sendEvent('view', `/product/${productId}`, null, productId, '/products');
}
```
- **Purpose:** Handles product view events
- **What it does:**
  - Finds product by ID
  - Sends 'view' event with product details

##### `purchaseProduct(productId)`
```javascript
function purchaseProduct(productId) {
    const product = products.find(p => p.id === productId);
    sendEvent('purchase', '/checkout', null, productId, `/product/${productId}`);
    alert(`✅ Purchase event sent for ${product.name}!`);
}
```
- **Purpose:** Handles purchase events
- **What it does:**
  - Finds product by ID
  - Sends 'purchase' event
  - Shows confirmation alert

#### **Product Data:**
```javascript
const products = [
    { id: 101, name: 'Laptop Pro', price: 1299, emoji: '💻' },
    { id: 202, name: 'Smartphone X', price: 899, emoji: '📱' },
    { id: 303, name: 'Tablet Air', price: 599, emoji: '📱' },
    { id: 404, name: 'Wireless Headphones', price: 199, emoji: '🎧' },
    { id: 505, name: 'Smart Watch', price: 399, emoji: '⌚' },
    { id: 606, name: 'Gaming Mouse', price: 79, emoji: '🖱️' }
];
```

---

## ⚡ Spark Streaming (`pyspark/apps/`)

### **1. `pyspark/apps/spark_streaming.py` - Spark Streaming Job**

**Purpose:** Consumes events from Kafka, processes them, and writes to MinIO and Kafka.

#### **Configuration Constants:**
```python
KAFKA_BROKERS = 'kafka0:29092'
KAFKA_CHECKPOINT = 'checkpoint'
ACME_PYSPARK_APP_NAME = 'AcmeSparkStreaming'
CLICKSTREAM_RAW_EVENTS_TOPIC = 'acme.clickstream.raw.events'
CLICKSTREAM_LATEST_EVENTS_TOPIC = 'acme.clickstream.latest.events'
checkpoint_directory = "/opt/spark-checkpoints/my-checkpoint"
```

#### **Functions:**

##### `initialize_spark_session(app_name)`
```python
def initialize_spark_session(app_name):
    """ Initialize the Spark Session with provided configurations. """
```
- **Purpose:** Creates Spark session
- **Parameters:** `app_name` (str) - Application name
- **Returns:** SparkSession or None on error
- **What it does:**
  - Creates SparkSession builder
  - Sets master to `spark://spark-master:7077`
  - Configures required packages (Kafka, Avro)
  - Sets log level to WARN
  - Returns session

##### `get_streaming_dataframe(spark, brokers, topic)`
```python
def get_streaming_dataframe(spark, brokers, topic):
    """ Get a streaming dataframe from Kafka """
```
- **Purpose:** Creates streaming DataFrame from Kafka
- **Parameters:**
  - `spark`: SparkSession
  - `brokers`: Kafka broker addresses
  - `topic`: Kafka topic name
- **Returns:** Streaming DataFrame or None
- **What it does:**
  - Configures Kafka source
  - Sets starting offset to "latest"
  - Sets `failOnDataLoss` to false
  - Returns streaming DataFrame

##### `transform_streaming_data(df, schema_registry_url, schema_id)`
```python
def transform_streaming_data(df, schema_registry_url, schema_id):
    """ Transform the initial dataframe """
```
- **Purpose:** Transforms raw Kafka data
- **Parameters:**
  - `df`: Input streaming DataFrame
  - `schema_registry_url`: Schema Registry URL
  - `schema_id`: Schema ID
- **Returns:** Transformed DataFrame
- **What it does:**
  - Fetches Avro schema from Schema Registry
  - Deserializes JSON from Kafka messages
  - Adds metadata (correlation_id, schema_id, ingested_timestamp)
  - Returns transformed DataFrame

##### `initiate_streaming_to_topic(df, brokers, topic, checkpoint)`
```python
def initiate_streaming_to_topic(df, brokers, topic, checkpoint):
    """ Start streaming the transformed data to the specified Kafka topic. """
```
- **Purpose:** Writes streaming data to Kafka topic
- **Parameters:**
  - `df`: Streaming DataFrame
  - `brokers`: Kafka broker addresses
  - `topic`: Target Kafka topic
  - `checkpoint`: Checkpoint location
- **What it does:**
  - Configures Kafka sink
  - Sets checkpoint location
  - Starts streaming query
  - Waits for termination

##### `main()`
```python
def main():
    spark = SparkSession.builder...
    # Sets up MinIO configuration
    # Reads from Kafka
    # Writes to MinIO and Kafka
```
- **Purpose:** Main execution function
- **What it does:**
  1. **Creates SparkSession**
  2. **Configures MinIO (S3-compatible):**
     - Sets access key: `minioadmin`
     - Sets secret key: `minioadmin`
     - Sets endpoint: `http://minio-storage:9000`
     - Disables SSL
     - Enables path-style access
  3. **Reads from Kafka:**
     - Topic: `acme.clickstream.raw.events`
     - Broker: `kafka0:29092`
  4. **Transforms data:**
     - Casts value to STRING
  5. **Writes to MinIO:**
     - Format: Parquet
     - Path: `s3a://acme.eu-west-1.stg.data.lake/clickstream-data`
     - Checkpoint: `/opt/spark-checkpoints/my-checkpoint/minio`
  6. **Writes to Kafka:**
     - Topic: `acme.clickstream.latest.events`
     - Checkpoint: `/opt/spark-checkpoints/my-checkpoint/kafka`
  7. **Waits for termination**

---

## 🐳 Docker Configuration

### **1. `docker-compose.yaml` - Service Orchestration**

**Purpose:** Defines all services and their configurations.

#### **Key Services:**

##### **Kafka (`kafka0`)**
- **Image:** `confluentinc/cp-kafka:7.6.1`
- **Ports:** 9092 (external), 29092 (internal)
- **Purpose:** Event streaming platform
- **Configuration:**
  - KRaft mode (no Zookeeper)
  - 6 partitions per topic
  - Replication factor: 1

##### **Schema Registry (`schema-registry0`)**
- **Image:** `confluentinc/cp-schema-registry:7.6.1`
- **Port:** 8085
- **Purpose:** Manages Avro schemas
- **Configuration:**
  - Connects to Kafka
  - Stores schemas in `_schemas` topic

##### **Spark Master (`spark-master`)**
- **Image:** `acme-spark` (custom built)
- **Ports:** 18080 (UI), 7077 (master)
- **Purpose:** Coordinates Spark cluster
- **Command:** `/usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master`

##### **Spark Worker (`spark-worker-1`)**
- **Image:** `acme-spark` (custom built)
- **Ports:** 28081 (UI), 7001
- **Purpose:** Processes data
- **Configuration:**
  - Connects to `spark://spark-master:7077`
  - 2 cores, 2GB memory
- **Command:** `/usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://spark-master:7077`

##### **MinIO (`minio-storage`)**
- **Image:** `minio/minio:latest`
- **Ports:** 9000 (API), 9001 (Console)
- **Purpose:** S3-compatible object storage
- **Credentials:** `minioadmin` / `minioadmin`

##### **Kafka UI (`kafka-ui`)**
- **Image:** `provectuslabs/kafka-ui:latest`
- **Port:** 8080
- **Purpose:** Web UI for Kafka management

---

### **2. `docker/spark/Dockerfile` - Spark Image**

**Purpose:** Custom Spark Docker image.

```dockerfile
FROM jupyter/pyspark-notebook:spark-3.3.0

USER root
RUN mkdir -p /usr/local/spark/work && chmod 777 /usr/local/spark/work
USER jovyan
```

- **Base Image:** Jupyter PySpark notebook (includes Spark 3.3.0)
- **What it does:**
  - Fixes permissions for Spark work directory
  - Ensures Spark can write to work directory

---

### **3. `docker/kafka-connect/Dockerfile` - Kafka Connect Image**

**Purpose:** Custom Kafka Connect image with connectors.

```dockerfile
FROM confluentinc/cp-kafka-connect:7.6.1

RUN confluent-hub install --no-prompt \
    confluentinc/kafka-connect-datagen:0.6.5 \
    confluentinc/kafka-connect-s3:10.5.10 \
    jcustenborder/kafka-connect-transform-common:latest \
    confluentinc/connect-transforms:1.4.6
```

- **Base Image:** Confluent Kafka Connect
- **Installed Connectors:**
  - Datagen (test data generation)
  - S3 (MinIO integration)
  - Transform Common (data transformations)
  - Connect Transforms (data manipulation)

---

## 📊 Event Generator (`generator/`)

### **1. `generator/generator.py` - Event Generator Script**

**Purpose:** Reads events from JSON file and sends them to API.

#### **Functions:**

##### `reset_state(state_file)`
```python
def reset_state(state_file):
    """ Reset the state by clearing the state file content. """
```
- **Purpose:** Clears state file to start from beginning
- **What it does:** Opens file in write mode (truncates it)

##### `save_state(state_file, last_read_line)`
```python
def save_state(state_file, last_read_line):
    """ Save the current state to a file. """
```
- **Purpose:** Saves progress (last read line number)
- **What it does:** Writes line number to file

##### `load_state(state_file)`
```python
def load_state(state_file):
    """ Load the last read state from a file. """
```
- **Purpose:** Loads saved progress
- **Returns:** Last read line number (0 if file doesn't exist)

##### `setup()`
```python
def setup():
    """ Setup necessary parameters """
```
- **Purpose:** Configures command-line arguments
- **Returns:** Parsed arguments and state file path
- **Arguments:**
  - `hostname`: API URL (default: `http://localhost:60000`)
  - `filename`: Events file path (default: `../data/events.json`)
  - `--reset`: Flag to reset state

##### `send_events(hostname, events)`
```python
def send_events(hostname, events):
    """ Send events to a REST API """
```
- **Purpose:** Sends events to API
- **Parameters:**
  - `hostname`: API base URL
  - `events`: List of event dictionaries
- **What it does:**
  - POSTs events to `/collect` endpoint
  - Handles errors

##### `generate_random_json_objects(hostname, filename, state_file)`
```python
def generate_random_json_objects(hostname, filename, state_file):
    # Reads file, sends events in batches
```
- **Purpose:** Main processing function
- **What it does:**
  1. Loads saved state (last read line)
  2. Opens events file
  3. Reads from last position
  4. Groups events into batches of 987
  5. Sends each batch to API
  6. Saves progress after each batch
  7. Waits 5 seconds between batches

---

## 📝 Configuration Files

### **1. `api/requirements.txt` - Python Dependencies**

```
flask==3.0.3          # Web framework
flask-cors==4.0.0     # CORS support
pytest==8.1.1         # Testing framework
requests==2.31.0      # HTTP client
kafka-python==2.0.2   # Kafka producer client
```

### **2. `schemas/` - Avro Schemas**

**Purpose:** Define data structure for events.

- `acme.clickstream.raw.events.avsc` - Avro schema
- `acme.clickstream.raw.events.json` - JSON schema
- `acme.clickstream.raw.events.proto` - Protocol Buffer schema

### **3. `connectors/` - Kafka Connect Configurations**

**Purpose:** Define Kafka Connect sink configurations.

- `acme.eu.clickstream.raw.s3.sink.json` - S3/MinIO sink for raw events
- `acme.eu.clickstream.invalid.s3.sink.json` - S3/MinIO sink for invalid events

---

## 🔄 Data Flow Summary

### **Complete Flow:**

1. **Event Generation:**
   - User interacts with demo website OR
   - Generator script reads from `data/events.json`

2. **API Reception:**
   - Events sent to `POST http://localhost:60000/collect`
   - `server.py` receives request
   - Calls `input.collect()`

3. **Validation & Kafka:**
   - `input.collect()` validates each event
   - Valid events sent to Kafka topic `acme.clickstream.raw.events`
   - Returns processing results

4. **Spark Processing:**
   - `spark_streaming.py` reads from Kafka
   - Transforms data
   - Writes to:
     - MinIO (Parquet format)
     - Kafka topic `acme.clickstream.latest.events`

5. **Storage:**
   - MinIO: `s3a://acme.eu-west-1.stg.data.lake/clickstream-data`
   - Kafka: `acme.clickstream.latest.events` topic

---

## 🎯 Key Design Patterns

1. **Singleton Pattern:** Kafka producer in `input.py`
2. **RESTful API:** Flask routes for event collection
3. **Stream Processing:** Spark Streaming for real-time processing
4. **Microservices:** Separate services for API, Spark, Kafka
5. **Containerization:** Docker Compose for orchestration
6. **Event-Driven:** Kafka as message queue

---

## 📚 Additional Resources

- **API Documentation:** See `api/server.py` for endpoints
- **Spark Documentation:** See `pyspark/apps/spark_streaming.py` for processing logic
- **Docker Configuration:** See `docker-compose.yaml` for service setup
- **Demo Website:** See `demo-website/index.html` for frontend code

---

**Last Updated:** 2024-11-12
**Version:** 1.0

