#!/bin/bash

# Alert Dispatcher - Fetches alerts from Prometheus API and logs them
# Usage: ./alert_dispatcher.sh

PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"
LOG_FILE="${LOG_FILE:-./alerts.log}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"

echo "==================================================" | tee -a "$LOG_FILE"
echo "Alert Dispatcher started at $(date)" | tee -a "$LOG_FILE"
echo "Prometheus URL: $PROMETHEUS_URL" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Check interval: ${CHECK_INTERVAL}s" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"
echo ""

# Function to fetch and log alerts
fetch_alerts() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Fetch alerts from Prometheus API
    local response=$(curl -s "${PROMETHEUS_URL}/api/v1/alerts")
    
    # Check if request was successful
    if [ $? -ne 0 ]; then
        echo "[$timestamp] ERROR: Failed to connect to Prometheus at $PROMETHEUS_URL" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # Parse alerts using jq (if available) or basic grep
    if command -v jq &> /dev/null; then
        # Parse with jq for pretty output
        local active_alerts=$(echo "$response" | jq -r '.data.alerts[] | select(.state == "firing")')
        local pending_alerts=$(echo "$response" | jq -r '.data.alerts[] | select(.state == "pending")')
        
        local firing_count=$(echo "$response" | jq -r '[.data.alerts[] | select(.state == "firing")] | length')
        local pending_count=$(echo "$response" | jq -r '[.data.alerts[] | select(.state == "pending")] | length')
        
        echo "[$timestamp] Alert Status: $firing_count firing, $pending_count pending" | tee -a "$LOG_FILE"
        
        # Log firing alerts
        if [ "$firing_count" -gt 0 ]; then
            echo "$response" | jq -r '.data.alerts[] | select(.state == "firing") | "  🔥 FIRING: \(.labels.alertname) - \(.annotations.summary // .annotations.description)"' | tee -a "$LOG_FILE"
        fi
        
        # Log pending alerts
        if [ "$pending_count" -gt 0 ]; then
            echo "$response" | jq -r '.data.alerts[] | select(.state == "pending") | "  ⏳ PENDING: \(.labels.alertname) - \(.annotations.summary // .annotations.description)"' | tee -a "$LOG_FILE"
        fi
        
        # No active alerts
        if [ "$firing_count" -eq 0 ] && [ "$pending_count" -eq 0 ]; then
            echo "  ✅ No active alerts" | tee -a "$LOG_FILE"
        fi
        
    else
        # Fallback: basic text parsing without jq
        echo "[$timestamp] Fetched alerts (jq not available, showing raw summary)" | tee -a "$LOG_FILE"
        
        # Count alerts by searching for "firing" and "pending" in response
        local firing_count=$(echo "$response" | grep -o '"state":"firing"' | wc -l)
        local pending_count=$(echo "$response" | grep -o '"state":"pending"' | wc -l)
        
        echo "  Alert Status: $firing_count firing, $pending_count pending" | tee -a "$LOG_FILE"
        
        if [ "$firing_count" -eq 0 ] && [ "$pending_count" -eq 0 ]; then
            echo "  ✅ No active alerts" | tee -a "$LOG_FILE"
        else
            echo "  Raw response logged for analysis" | tee -a "$LOG_FILE"
            echo "$response" >> "$LOG_FILE"
        fi
    fi
    
    echo "" | tee -a "$LOG_FILE"
}

# Run once if --once flag is provided
if [ "$1" == "--once" ]; then
    fetch_alerts
    exit 0
fi

# Continuous monitoring mode
echo "Running in continuous mode. Press Ctrl+C to stop."
echo ""

while true; do
    fetch_alerts
    sleep "$CHECK_INTERVAL"
done
