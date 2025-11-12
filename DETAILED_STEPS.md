# Click Streaming Data Pipeline - Detailed Steps Guide
## Complete Step-by-Step Instructions for Running and Demonstrating

---

## 📚 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Starting All Services](#starting-all-services)
4. [Starting Application Components](#starting-application-components)
5. [Sending Test Events](#sending-test-events)
6. [Demonstrating Each Component](#demonstrating-each-component)
7. [Complete Demonstration Script](#complete-demonstration-script)
8. [Troubleshooting](#troubleshooting)
9. [Emergency Commands](#emergency-commands)

---

## 🔧 Prerequisites

### **Required Software:**
- ✅ Docker Desktop (with Docker Compose)
- ✅ Python 3.11+
- ✅ 8GB+ RAM (recommended)
- ✅ PowerShell (Windows) or Bash (Linux/Mac)

### **Verify Installation:**
```powershell
# Check Docker
docker --version
docker compose version

# Check Python
python --version
```

---

## 🚀 Initial Setup

### **Step 1: Navigate to Project Directory**
```powershell
cd D:\BDA\Click-Streaming-Data-Pipeline
```

### **Step 2: Verify Project Structure**
You should see:
- `docker-compose.yaml` - Service configuration
- `api/` - API server code
- `generator/` - Event generator
- `pyspark/` - Spark streaming jobs
- `data/` - Sample event data

---

## 🐳 Starting All Services

### **Step 1: Start Docker Services**
```powershell
docker compose up -d --build
```

**What this does:**
- Builds custom Docker images (Spark, Kafka Connect)
- Starts all services in detached mode
- Services include: Kafka, Spark, MinIO, Schema Registry, etc.

**Wait Time:** 2-3 minutes for all services to start

### **Step 2: Verify Services are Running**
```powershell
docker compose ps
```

**Expected Output:**
You should see these services with status "Up":
- ✅ kafka0
- ✅ spark-master
- ✅ spark-worker-1
- ✅ minio-storage
- ✅ kafka-ui
- ✅ schema-registry0
- ✅ kafka-connect0
- ✅ rest-proxy
- ✅ ksqldb-server

**If services are not running:**
```powershell
# Check logs
docker compose logs kafka0
docker compose logs spark-master

# Restart specific service
docker compose restart kafka0
```

### **Step 3: Create Kafka Topics**
```powershell
# Create raw events topic
docker exec kafka0 kafka-topics --create --topic acme.clickstream.raw.events --partitions 6 --replication-factor 1 --bootstrap-server localhost:9092 --if-not-exists

# Create latest events topic
docker exec kafka0 kafka-topics --create --topic acme.clickstream.latest.events --partitions 6 --replication-factor 1 --bootstrap-server localhost:9092 --if-not-exists

# Create invalid events topic
docker exec kafka0 kafka-topics --create --topic acme.clickstream.invalid.events --partitions 6 --replication-factor 1 --bootstrap-server localhost:9092 --if-not-exists

# Verify topics created
docker exec kafka0 kafka-topics --list --bootstrap-server localhost:9092
```

**Expected Output:**
```
acme.clickstream.raw.events
acme.clickstream.latest.events
acme.clickstream.invalid.events
```

---

## 🚀 Starting Application Components

### **Step 1: Start API Server**

**Open a NEW terminal window:**

```powershell
cd D:\BDA\Click-Streaming-Data-Pipeline\api

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# If venv doesn't exist, create it:
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Start API server
python server.py
```

**Expected Output:**
```
 * Running on http://0.0.0.0:60000
```

**Keep this terminal open!** The API server must stay running.

### **Step 2: Verify API is Working**
```powershell
# In a new terminal, test the API
curl http://localhost:60000/ping
```

**Expected Response:**
```json
{"status": "OK"}
```

### **Step 3: (Optional) Start Event Generator**

**Open another NEW terminal:**

```powershell
cd D:\BDA\Click-Streaming-Data-Pipeline\generator

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# If venv doesn't exist, create it:
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Start generator
python generator.py
```

**Note:** The generator reads from `data/events.json`. For demo purposes, we'll send events directly to Kafka instead.

---

## 📨 Sending Test Events

### **Method 1: Send Events Directly to Kafka (Recommended for Demo)**

**Open a new terminal and run:**

```powershell
cd D:\BDA\Click-Streaming-Data-Pipeline

# Event 1 - Click Event
echo '{"id": 1, "type": "click", "package_id": "demo-1", "event": {"user_agent": "Mozilla/5.0", "ip": "192.168.1.1", "customer_id": 12345, "timestamp": "2024-11-12T15:00:00Z", "page": "/home", "query": null, "product": null, "referrer": "https://google.com", "position": null}}' | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events

# Event 2 - View Event
echo '{"id": 2, "type": "view", "package_id": "demo-2", "event": {"user_agent": "Chrome/120.0", "ip": "192.168.1.2", "customer_id": 12346, "timestamp": "2024-11-12T15:01:00Z", "page": "/products", "query": "laptop", "product": 101, "referrer": "https://google.com", "position": 1}}' | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events

# Event 3 - Purchase Event
echo '{"id": 3, "type": "purchase", "package_id": "demo-3", "event": {"user_agent": "Safari/17.0", "ip": "192.168.1.3", "customer_id": 12347, "timestamp": "2024-11-12T15:02:00Z", "page": "/checkout", "query": null, "product": 101, "referrer": "/product/101", "position": null}}' | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events
```

**Expected Output:**
Each command should complete without errors. Events are now in Kafka.

### **Method 2: Send Events via API**

```powershell
# Send test event to API
curl -X POST http://localhost:60000/collect -H "Content-Type: application/json" -d '{"id": 999, "type": "click", "package_id": "api-test", "event": {"user_agent": "Test/1.0", "ip": "10.0.0.1", "customer_id": 99999, "timestamp": "2024-11-12T15:00:00Z", "page": "/test"}}'
```

---

## 🎬 Demonstrating Each Component

### **1. Kafka UI Demonstration**

**URL:** http://localhost:8080

**Steps:**
1. Open browser and navigate to http://localhost:8080
2. Click on "Topics" in left sidebar
3. Click on `acme.clickstream.raw.events`
4. Go to "Messages" tab
5. Configure filters:
   - **Seek Type**: "Latest" (or "Offset" with empty/high number like 999999 for newest events)
   - **Partitions**: "All items are selected" ⚠️ **IMPORTANT: Check all partitions**
   - **Key Serde**: "String"
   - **Value Serde**: "String" ⚠️ **IMPORTANT: Must be String, not SchemaRegistry**
6. Click "Submit"
7. **Scroll to the BOTTOM** of the messages table (newest events are at the bottom!)
8. You should see events with latest timestamps

**⚠️ Important Notes:**
- **Newest events appear at the BOTTOM**, not the top
- Events are distributed across partitions (0, 1, 2, 3, 4, 5) - check all partitions
- After sending new events from the website, click "Submit" again to refresh
- Look at the "Timestamp" column to find the most recent events

**What to Show:**
- Events in the table
- Partition distribution (events in different partitions)
- Event structure (click on a message to see full JSON)
- Timestamps

**What to Say:**
> "This is Kafka UI showing events in our topic. Notice how events are distributed across different partitions. This enables parallel processing by multiple worker nodes."

---

### **2. Spark UI Demonstration**

**URL:** http://localhost:18080

**Steps:**
1. Open browser and navigate to http://localhost:18080
2. Look at the Summary section:
   - Point to "Alive Workers: 1"
   - Point to "Cores: 2 Total"
   - Point to "Memory: 2.0 GiB Total"
3. Click on "Workers" tab (or scroll down)
4. Show worker details:
   - Worker ID
   - State: ALIVE
   - Cores: 2 (0 Used)
   - Memory: 2.0 GiB (0.0 B Used)

**What to Show:**
- Summary statistics
- Worker node details
- Resource allocation

**What to Say:**
> "This is the Spark Master dashboard. It shows our distributed computing cluster with 1 worker node. The worker has 2 CPU cores and 2GB of memory available. In production, we'd have many more workers processing data in parallel."

---

### **3. MinIO Console Demonstration**

**URL:** http://localhost:9001

**Steps:**
1. Open browser and navigate to http://localhost:9001
2. Login:
   - **Username**: `minioadmin`
   - **Password**: `minioadmin`
3. Click on "Buckets" in left sidebar
4. Click on bucket: `acme.eu-west-1.stg.data.lake`
5. Navigate through folder structure
6. Show Parquet files (if any exist)

**What to Show:**
- Bucket structure
- Data organization
- File formats

**What to Say:**
> "This is our data lake - where processed data is stored. Data is organized by time and stored in Parquet format, which is efficient for analytics queries."

---

### **4. API Server Demonstration**

**URL:** http://localhost:60000

**Steps:**
1. Test health endpoint:
   ```powershell
   curl http://localhost:60000/ping
   ```
2. Show API is responding
3. Explain it's receiving and validating events

**What to Say:**
> "This is our API server - the entry point for all events. It receives events, validates them, and ensures data quality before they enter the pipeline."

---

## 🎬 Complete Demonstration Script

### **Pre-Demo Setup (5 minutes)**

1. **Start All Services:**
   ```powershell
   cd D:\BDA\Click-Streaming-Data-Pipeline
   docker compose up -d
   ```

2. **Wait for Services:**
   ```powershell
   # Wait 2-3 minutes, then check
   docker compose ps
   ```

3. **Start API Server:**
   ```powershell
   cd api
   .\venv\Scripts\Activate.ps1
   python server.py
   ```
   (Keep terminal open)

---

### **Demo Script (15-20 minutes)**

#### **Part 1: Introduction (2 minutes)**

**Say:**
> "This is a real-time big data processing pipeline for clickstream events. It demonstrates how companies like Amazon, Netflix, and Uber process millions of user events in real-time using distributed worker nodes."

**Show:**
- Architecture overview
- List of technologies

---

#### **Part 2: Architecture Overview (3 minutes)**

**Say:**
> "The pipeline has 4 main stages:
> 1. Event ingestion - API receives events
> 2. Event streaming - Kafka queues events
> 3. Stream processing - Spark workers process events
> 4. Data storage - MinIO stores processed data"

**Show:**
- Component diagram
- Explain each component's role

---

#### **Part 3: Live Demonstration (10 minutes)**

**3.1 Show Kafka UI (3 minutes)**
- Open http://localhost:8080
- Show topics
- Send test events (use commands from "Sending Test Events" section)
- Show events appearing in Kafka UI
- Explain partitioning

**3.2 Show Spark UI (3 minutes)**
- Open http://localhost:18080
- Show Spark Master dashboard
- Show Workers tab
- Explain worker nodes and distributed processing

**3.3 Show MinIO (2 minutes)**
- Open http://localhost:9001
- Login and show bucket structure
- Explain data lake concept

**3.4 Show API (2 minutes)**
- Test API endpoint
- Show validation in action

---

#### **Part 4: Key Features (2 minutes)**

**Emphasize:**
1. **Real-time Processing**: Events processed as they arrive
2. **Distributed Computing**: Worker nodes processing in parallel
3. **Scalability**: Can handle millions of events
4. **Industry Standards**: Kafka, Spark, S3 patterns

---

#### **Part 5: Q&A (3 minutes)**

**Common Questions:**

**Q: Why use Kafka?**
A: "Kafka is the industry standard for event streaming. It handles high throughput, provides durability, and decouples producers from consumers."

**Q: What are worker nodes?**
A: "Worker nodes are separate compute units that process data in parallel. More workers = faster processing and better scalability."

**Q: Is this production-ready?**
A: "Yes, this uses production-grade technologies and patterns. Companies use this exact architecture."

**Q: How does it scale?**
A: "We can add more Kafka partitions, more Spark workers, and more storage. The architecture supports horizontal scaling."

---

## 🔍 Troubleshooting

### **Problem 1: New events not appearing in Kafka UI (showing old data only)**

**Symptoms:**
- Kafka UI shows old events but not new ones from the website
- Events sent from demo website don't appear in Kafka UI
- Only seeing test events from earlier

**Solutions:**

1. **Check Kafka UI Configuration:**
   - Set "Seek Type" to "Latest" (or leave offset empty)
   - Set "Value Serde" to "String" (NOT SchemaRegistry)
   - Make sure "Partitions" shows "All items are selected"
   - Click "Submit" button

2. **Scroll to Bottom:**
   - Newest events appear at the **BOTTOM** of the messages table, not the top
   - Scroll down to see the most recent events
   - Look at the "Timestamp" column - newest events have the latest time

3. **Check All Partitions:**
   - Events are distributed across partitions (0, 1, 2, 3, 4, 5)
   - A new event might be in a different partition
   - Make sure "All items are selected" in Partitions dropdown

4. **Refresh After Sending:**
   - After clicking a product on the website, go to Kafka UI
   - Click "Submit" button again (this refreshes the view)
   - Scroll to bottom to see the new event

5. **Check API Server:**
   - Look at the API server window (PowerShell running server.py)
   - Should show: "Event sent to Kafka: [number]"
   - If you see errors, the API might not be sending to Kafka

6. **Verify Event Format:**
   - Click on a message row to expand it
   - Click "Value Preview" to see full JSON
   - Should see `product_name` and `product_price` fields

**Quick Test:**
```powershell
# Send test event directly to Kafka
$testEvent = '{"id": ' + [int](Get-Date -UFormat %s) + ', "type": "test", "package_id": "test-' + (Get-Date -Format "HHmmss") + '", "event": {"user_agent": "Test", "ip": "192.168.1.1", "customer_id": 99999, "timestamp": "' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") + '", "page": "/test", "query": null, "product": 101, "product_name": "Laptop Pro", "product_price": 1299, "referrer": "direct", "position": null}}'
echo $testEvent | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events
```
Then check Kafka UI - you should see this event with current timestamp.

---

### **Problem 2: No messages in Kafka UI**

**Symptoms:**
- Kafka UI shows "No messages found"
- Topics are empty

**Solutions:**
1. **Check Value Serde**: Must be set to "String" (not SchemaRegistry)
2. **Send test events**: Use commands from "Sending Test Events" section
3. **Check topic exists**: Run `docker exec kafka0 kafka-topics --list --bootstrap-server localhost:9092`

---

### **Problem 2: Services not starting**

**Symptoms:**
- `docker compose ps` shows services as "Exited" or "Restarting"

**Solutions:**
1. **Check Docker resources**: Allocate more RAM (8GB+ recommended)
2. **Check logs**: `docker compose logs <service-name>`
3. **Restart services**: `docker compose restart <service-name>`
4. **Rebuild if needed**: `docker compose up -d --build`

---

### **Problem 3: API not responding**

**Symptoms:**
- `curl http://localhost:60000/ping` fails
- Connection refused error

**Solutions:**
1. **Check if API is running**: Look for Python process
2. **Start API server**: Follow "Starting Application Components" section
3. **Check port conflict**: Another service might be using port 60000

---

### **Problem 4: Spark workers not showing**

**Symptoms:**
- Spark UI shows "Alive Workers: 0"
- No workers in Workers tab

**Solutions:**
1. **Check worker status**: `docker compose ps spark-worker-1`
2. **Restart workers**: `docker compose restart spark-worker-1`
3. **Check logs**: `docker compose logs spark-worker-1`
4. **Rebuild if needed**: `docker compose build spark-builder`

---

### **Problem 5: Red exclamation marks in Kafka UI**

**Symptoms:**
- Events show red exclamation marks
- Can't see event content

**Solution:**
- **Change Value Serde**: From "SchemaRegistry" to "String"
- Events are plain JSON, not Avro-encoded

---

## 🆘 Emergency Commands

### **Check All Services**
```powershell
docker compose ps
```

### **View Service Logs**
```powershell
# Kafka logs
docker compose logs kafka0 --tail 50

# Spark logs
docker compose logs spark-master --tail 50
docker compose logs spark-worker-1 --tail 50

# All services
docker compose logs --tail 50
```

### **Restart Everything**
```powershell
docker compose down
docker compose up -d
```

### **Restart Specific Service**
```powershell
docker compose restart kafka0
docker compose restart spark-master
docker compose restart spark-worker-1
```

### **Check Kafka Topics**
```powershell
docker exec kafka0 kafka-topics --list --bootstrap-server localhost:9092
```

### **Check Topic Messages**
```powershell
docker exec kafka0 kafka-console-consumer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events --from-beginning --max-messages 5
```

### **Test API**
```powershell
curl http://localhost:60000/ping
```

### **Send Quick Test Event**
```powershell
echo '{"id": 999, "type": "click", "package_id": "quick-test", "event": {"user_agent": "Test", "ip": "1.1.1.1", "customer_id": 999, "timestamp": "2024-11-12T15:00:00Z", "page": "/test"}}' | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events
```

---

## ✅ Pre-Demo Checklist

Before starting your demonstration:

- [ ] All Docker services running (`docker compose ps`)
- [ ] API server started and responding (`curl http://localhost:60000/ping`)
- [ ] Kafka topics created (check with `kafka-topics --list`)
- [ ] Kafka UI accessible (http://localhost:8080)
- [ ] Spark UI accessible (http://localhost:18080)
- [ ] MinIO accessible (http://localhost:9001)
- [ ] Test events ready to send (commands prepared)
- [ ] Architecture understood
- [ ] Key talking points memorized

---

## 🎯 Quick Reference

### **Key URLs:**
- Kafka UI: http://localhost:8080
- Spark UI: http://localhost:18080
- MinIO Console: http://localhost:9001 (minioadmin/minioadmin)
- Schema Registry: http://localhost:8085
- KSQL Server: http://localhost:8088
- API Server: http://localhost:60000

### **Key Commands:**
```powershell
# Start everything
docker compose up -d

# Check status
docker compose ps

# Send test event
echo '{"id": 1, "type": "click", ...}' | docker exec -i kafka0 kafka-console-producer --bootstrap-server localhost:9092 --topic acme.clickstream.raw.events

# Test API
curl http://localhost:60000/ping
```

---

**You're ready to demonstrate!** 🚀

