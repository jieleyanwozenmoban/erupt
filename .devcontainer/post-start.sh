#!/bin/bash
# Post-start script runs every time the container starts
set -e

echo "========================================="
echo "Erupt Dev Container - Starting..."
echo "========================================="

# Check if services are healthy
check_service_health() {
    local service=$1
    local host=$2
    local port=$3
    
    if nc -z -w5 "$host" "$port" 2>/dev/null; then
        echo "✓ $service is available at $host:$port"
        return 0
    else
        echo "⚠ $service is not available at $host:$port"
        return 1
    fi
}

# Wait a moment for services to start
sleep 3

echo "Checking service connectivity..."
check_service_health "MySQL" "mysql" 3306 || true
check_service_health "Redis" "redis" 6379 || true

echo ""
echo "========================================="
echo "Environment Information"
echo "========================================="
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Maven: $(mvn -version 2>&1 | head -n 1)"
echo "Workspace: $(pwd)"
echo "========================================="
echo ""
