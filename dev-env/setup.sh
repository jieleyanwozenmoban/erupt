#!/bin/bash
# Erupt Development Environment Setup Script
# Usage: ./dev-env/setup.sh [start|stop|restart|status|clean|logs]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
ENV_FILE="$SCRIPT_DIR/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    echo -e "${GREEN}✓${NC} Loaded environment variables from .env"
else
    echo -e "${YELLOW}⚠${NC} No .env file found, using defaults from .env.example"
    if [ -f "$SCRIPT_DIR/.env.example" ]; then
        export $(grep -v '^#' "$SCRIPT_DIR/.env.example" | xargs)
    fi
fi

# Functions
print_help() {
    echo -e "${BLUE}Erupt Development Environment Manager${NC}"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start       Start development environment (MySQL + Redis)"
    echo "  start:tools Start with admin tools (Adminer + Redis Commander)"
    echo "  stop        Stop development environment"
    echo "  restart     Restart development environment"
    echo "  status      Show service status"
    echo "  logs        Show service logs"
    echo "  clean       Stop and remove all containers and volumes"
    echo "  init        Initialize local development environment"
    echo "  test        Run Maven tests with development environment"
    echo "  help        Show this help message"
    echo ""
}

start_services() {
    echo -e "${BLUE}Starting Erupt development environment...${NC}"
    cd "$SCRIPT_DIR"
    docker compose -f "$COMPOSE_FILE" up -d
    
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"
    wait_for_services
    
    echo -e "${GREEN}✓${NC} Development environment started successfully!"
    print_connection_info
}

start_with_tools() {
    echo -e "${BLUE}Starting Erupt development environment with tools...${NC}"
    cd "$SCRIPT_DIR"
    docker compose -f "$COMPOSE_FILE" --profile tools up -d
    
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"
    wait_for_services
    
    echo -e "${GREEN}✓${NC} Development environment with tools started successfully!"
    print_connection_info
}

stop_services() {
    echo -e "${BLUE}Stopping Erupt development environment...${NC}"
    cd "$SCRIPT_DIR"
    docker compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✓${NC} Services stopped"
}

restart_services() {
    stop_services
    start_services
}

show_status() {
    echo -e "${BLUE}Erupt Development Environment Status${NC}"
    cd "$SCRIPT_DIR"
    docker compose -f "$COMPOSE_FILE" ps
}

show_logs() {
    cd "$SCRIPT_DIR"
    docker compose -f "$COMPOSE_FILE" logs -f --tail=100 "$@"
}

clean_environment() {
    echo -e "${YELLOW}⚠${NC} This will remove all containers and volumes!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$SCRIPT_DIR"
        docker compose -f "$COMPOSE_FILE" down -v --remove-orphans
        echo -e "${GREEN}✓${NC} Environment cleaned"
    else
        echo -e "${BLUE}Cancelled${NC}"
    fi
}

wait_for_services() {
    local max_attempts=30
    local attempt=0
    
    echo -e "${YELLOW}Checking MySQL...${NC}"
    while [ $attempt -lt $max_attempts ]; do
        if docker compose -f "$COMPOSE_FILE" exec -T mysql mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-root123}" &>/dev/null; then
            echo -e "${GREEN}✓${NC} MySQL is ready"
            break
        fi
        attempt=$((attempt + 1))
        sleep 2
    done
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${RED}✗${NC} MySQL failed to start"
        return 1
    fi
    
    echo -e "${YELLOW}Checking Redis...${NC}"
    attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if docker compose -f "$COMPOSE_FILE" exec -T redis redis-cli -a "${REDIS_PASSWORD:-redis123}" ping &>/dev/null; then
            echo -e "${GREEN}✓${NC} Redis is ready"
            break
        fi
        attempt=$((attempt + 1))
        sleep 2
    done
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${RED}✗${NC} Redis failed to start"
        return 1
    fi
}

print_connection_info() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Connection Information${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}MySQL:${NC}"
    echo -e "  Host: localhost:${MYSQL_PORT:-3306}"
    echo -e "  Database: ${MYSQL_DATABASE:-erupt_dev}"
    echo -e "  Username: ${MYSQL_USER:-erupt}"
    echo -e "  Password: ${MYSQL_PASSWORD:-erupt123}"
    echo ""
    echo -e "${GREEN}Redis:${NC}"
    echo -e "  Host: localhost:${REDIS_PORT:-6379}"
    echo -e "  Password: ${REDIS_PASSWORD:-redis123}"
    echo ""
    echo -e "${GREEN}Adminer (if started):${NC}"
    echo -e "  URL: http://localhost:${ADMINER_PORT:-8080}"
    echo ""
    echo -e "${GREEN}Redis Commander (if started):${NC}"
    echo -e "  URL: http://localhost:${REDIS_COMMANDER_PORT:-8081}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

init_local_env() {
    echo -e "${BLUE}Initializing local development environment...${NC}"
    
    # Create .env if not exists
    if [ ! -f "$ENV_FILE" ]; then
        cp "$SCRIPT_DIR/.env.example" "$ENV_FILE"
        echo -e "${GREEN}✓${NC} Created .env file from template"
    else
        echo -e "${YELLOW}⚠${NC} .env file already exists, skipping"
    fi
    
    # Create Maven settings if not exists
    MAVEN_DIR="$HOME/.m2"
    MAVEN_SETTINGS="$MAVEN_DIR/settings.xml"
    
    if [ ! -f "$MAVEN_SETTINGS" ]; then
        echo -e "${YELLOW}Creating Maven settings.xml...${NC}"
        mkdir -p "$MAVEN_DIR"
        cat > "$MAVEN_SETTINGS" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>aliyun-maven</id>
            <mirrorOf>central</mirrorOf>
            <name>Aliyun Maven Mirror</name>
            <url>https://maven.aliyun.com/repository/central</url>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>jdk-17</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <maven.compiler.source>17</maven.compiler.source>
                <maven.compiler.target>17</maven.compiler.target>
                <maven.compiler.release>17</maven.compiler.release>
            </properties>
        </profile>
    </profiles>
</settings>
EOF
        echo -e "${GREEN}✓${NC} Created Maven settings.xml"
    else
        echo -e "${YELLOW}⚠${NC} Maven settings.xml already exists, skipping"
    fi
    
    # Check Java version
    if command -v java &>/dev/null; then
        java_version=$(java -version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} Java: $java_version"
    else
        echo -e "${RED}✗${NC} Java not found. Please install JDK 17+"
    fi
    
    # Check Maven version
    if command -v mvn &>/dev/null; then
        mvn_version=$(mvn -version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} Maven: $mvn_version"
    else
        echo -e "${RED}✗${NC} Maven not found. Please install Maven 3.6+"
    fi
    
    echo ""
    echo -e "${GREEN}✓${NC} Local environment initialization complete!"
}

run_tests() {
    echo -e "${BLUE}Running Maven tests...${NC}"
    cd "$PROJECT_DIR"
    
    # Check if services are running
    if ! docker compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        echo -e "${YELLOW}Services not running, starting...${NC}"
        start_services
    fi
    
    # Run tests
    mvn clean test -Dspring.profiles.active=dev
}

# Main command handler
case "${1:-help}" in
    start)
        start_services
        ;;
    start:tools)
        start_with_tools
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        shift
        show_logs "$@"
        ;;
    clean)
        clean_environment
        ;;
    init)
        init_local_env
        ;;
    test)
        run_tests
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac
