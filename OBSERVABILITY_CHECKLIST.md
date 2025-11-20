# Observability Setup Checklist ✅

## ✅ Requirements Met

### 1. Monitor local web service in Docker
- ✅ Backend (login_backend container) running
- ✅ Frontend (login_frontend container) running
- ✅ Database (login_db container) running
- ✅ Nginx reverse proxy (login_nginx container) running

### 2. Collect metrics: CPU, memory, response time
- ✅ **CPU metrics**: cAdvisor tracks container CPU usage
- ✅ **Memory metrics**: cAdvisor tracks container memory
- ✅ **Response time**: Backend exposes `http_request_duration_seconds` histogram
- ✅ **System metrics**: Node Exporter provides host-level CPU/memory

### 3. Visualize metrics in dashboard
- ✅ Grafana running on port 3000
- ✅ Anonymous access enabled (no login required)
- ✅ Dashboard auto-provisioned: "Login App Observability Dashboard"
- ✅ Prometheus datasource pre-configured

### 4. Trigger alerts: unhealthy app or CPU > 70%
- ✅ Alert: `HighCPUUsage` - fires when container CPU > 70% for 1 min
- ✅ Alert: `BackendDown` - fires when backend /metrics is down for 30s
- ✅ Alert: `HighMemoryUsage` - fires when container memory > 80% for 2 min
- ✅ Alert rules file: `prometheus/alert.rules.yml`

### 5. Use Prometheus, Node Exporter, Grafana via docker-compose
- ✅ Prometheus: scraping 4 targets (prometheus, backend, node-exporter, cadvisor)
- ✅ Node Exporter: collecting system metrics
- ✅ Grafana: visualizing all metrics
- ✅ cAdvisor: collecting container metrics

### 6. Expose /metrics endpoint from demo app
- ✅ Backend exposes `/metrics` at port 4000
- ✅ Metrics include:
  - Default Node.js process metrics (CPU, memory, event loop)
  - Custom `http_request_duration_seconds` (response time histogram)
  - Custom `http_requests_total` (request counter)

### 7. Configure Prometheus scrape targets and alert rules
- ✅ Scrape config: `prometheus/prometheus.yml`
  - prometheus:9090
  - backend:4000
  - node-exporter:9100
  - cadvisor:8080
- ✅ Alert rules: `prometheus/alert.rules.yml` (3 rules configured)

### 8. Import basic Grafana dashboard
- ✅ Dashboard JSON: `grafana/dashboards/login-app-dashboard.json`
- ✅ Dashboard provisioning: `grafana/dashboards/dashboard.yaml`
- ✅ Auto-loaded on Grafana startup

---

## 📸 Screenshots to Take

### 1. Grafana Dashboard (http://localhost:3000)
- Show the main "Login App Observability Dashboard"
- Should display:
  - Container CPU Usage graph
  - Container Memory Usage graph
  - HTTP Response Time (p95) graph
  - Backend Status gauge (should show "UP")
  - HTTP Request Rate graph
  - Node Memory Usage graph
  - Node CPU Usage graph

### 2. Prometheus Targets (http://localhost:9090/targets)
- Show all 4 targets in "UP" state:
  - backend (1/1 up)
  - cadvisor (1/1 up)
  - node (1/1 up)
  - prometheus (1/1 up)

### 3. Prometheus Alerts (http://localhost:9090/alerts)
- Show the configured alert rules:
  - HighCPUUsage (inactive)
  - BackendDown (inactive)
  - HighMemoryUsage (inactive)

### 4. Backend Metrics Endpoint (http://localhost:4000/metrics)
- Show raw Prometheus metrics from the backend
- Should include metrics like:
  - `http_request_duration_seconds_bucket`
  - `http_requests_total`
  - `nodejs_heap_size_total_bytes`
  - `process_cpu_seconds_total`

### 5. Working Application (http://localhost)
- Show the login form working
- Register/login to generate some metrics

---

## 🚀 How to Run

```bash
# Stop any existing containers
docker compose down

# Start fresh (rebuilds backend with metrics support)
docker compose up --build -d

# Wait ~30 seconds for all services to be healthy

# Check container status
docker compose ps

# Access services:
# - App: http://localhost
# - Grafana: http://localhost:3000
# - Prometheus: http://localhost:9090
# - cAdvisor: http://localhost:8080
```

---

## 🧪 Test Metrics Collection

```bash
# Generate some traffic to create metrics
curl -X POST http://localhost/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

curl -X POST http://localhost/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# View backend metrics
curl http://localhost:4000/metrics

# Check Prometheus is scraping backend
curl -s http://localhost:9090/api/v1/targets | grep backend
```

---

## 🔧 Troubleshooting

### If Grafana asks for login:
- Username: `admin`
- Password: `grafana`
- (Anonymous access is enabled, but you can still log in)

### If backend shows DOWN in Prometheus:
1. Check backend logs: `docker compose logs backend`
2. Verify /metrics works: `curl http://localhost:4000/metrics`
3. Restart: `docker compose restart backend prometheus`

### If dashboard is empty:
1. Wait 15-30 seconds for first scrape
2. Generate traffic by using the app
3. Refresh Grafana dashboard
4. Check Prometheus targets: http://localhost:9090/targets

---

## ✨ Bonus Features Implemented

- ✅ Container names for easier management
- ✅ Health checks on database
- ✅ Automatic retry logic for backend DB connection
- ✅ Nginx reverse proxy (single entry point on port 80)
- ✅ Persistent volumes for Grafana & Prometheus data
- ✅ CI/CD deployment to Azure VM
