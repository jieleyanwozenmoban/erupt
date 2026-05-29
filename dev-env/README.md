# Erupt Development Environment

This directory contains the unified development environment configuration for the Erupt project. It supports both **VSCode Dev Container** and **Docker Compose** startup methods, with automatic database and Redis initialization.

## Quick Start

### Option 1: VSCode Dev Container (Recommended)

1. Install [Docker](https://docs.docker.com/get-docker/) and [VSCode Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
2. Open the project in VSCode
3. Click "Reopen in Container" when prompted, or press `F1` and select `Dev Containers: Reopen in Container`
4. Wait for the container to build and services to start

### Option 2: Docker Compose (Manual Setup)

```bash
# Initialize local environment
./dev-env/setup.sh init

# Start development services (MySQL + Redis)
./dev-env/setup.sh start

# Start with admin tools (includes Adminer + Redis Commander)
./dev-env/setup.sh start:tools

# Check service status
./dev-env/setup.sh status

# View logs
./dev-env/setup.sh logs

# Stop services
./dev-env/setup.sh stop

# Clean all data
./dev-env/setup.sh clean
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Dev Container                   │
│  ┌─────────────────────────────────────────┐    │
│  │          VSCode + Extensions            │    │
│  │  - Java Extension Pack                  │    │
│  │  - Spring Boot Tools                    │    │
│  │  - Maven for Java                       │    │
│  │  - Docker                               │    │
│  └─────────────────────────────────────────┘    │
│                      │                          │
│  ┌───────────────────▼───────────────────┐      │
│  │       erupt-dev (Build Container)     │      │
│  │  - JDK 17                             │      │
│  │  - Maven 3.9.9                        │      │
│  │  - Git, Zsh                           │      │
│  └───────────────────────────────────────┘      │
└──────────────────────┬──────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌────────┐    ┌────────┐    ┌────────┐
   │ MySQL  │    │ Redis  │    │Adminer │ (optional)
   │ :3306  │    │ :6379  │    │ :8080  │
   └────────┘    └────────┘    └────────┘
```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and modify as needed:

```bash
cp dev-env/.env.example dev-env/.env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_PORT` | 3306 | MySQL port |
| `MYSQL_ROOT_PASSWORD` | root123 | MySQL root password |
| `MYSQL_DATABASE` | erupt_dev | Main development database |
| `MYSQL_USER` | erupt | MySQL user |
| `MYSQL_PASSWORD` | erupt123 | MySQL user password |
| `REDIS_PORT` | 6379 | Redis port |
| `REDIS_PASSWORD` | redis123 | Redis password |
| `ADMINER_PORT` | 8080 | Adminer web UI port |
| `REDIS_COMMANDER_PORT` | 8081 | Redis Commander web UI port |

### Maven Configuration

A pre-configured Maven settings file is provided at `dev-env/maven-settings.xml` with:
- Aliyun mirror for faster downloads in China
- JDK 17 compiler settings
- Development profile

To use it:
```bash
cp dev-env/maven-settings.xml ~/.m2/settings.xml
```

### Spring Boot Profiles

The development environment includes `application-dev.yml` with pre-configured:
- MySQL datasource with HikariCP connection pool
- Redis with Lettuce connection pool
- Hibernate DDL auto-update
- Debug logging for Erupt and Hibernate

## Development Workflow

### Build Project

```bash
# Full build (skip tests)
mvn clean install -DskipTests

# Build with tests
mvn clean test

# Build specific module
mvn clean install -pl erupt-core -am
```

### Run Application

```bash
# Using Maven Spring Boot plugin
mvn spring-boot:run -pl erupt-sample -Dspring-boot.run.profiles=dev

# Or run the sample application directly
cd erupt-sample
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Run Tests

```bash
# Run all tests
mvn test

# Run tests with dev profile
./dev-env/setup.sh test

# Run specific module tests
mvn test -pl erupt-core
```

### Debug in VSCode

1. Open the project in Dev Container
2. Go to Run and Debug view (`Ctrl+Shift+D`)
3. Select "Launch Erupt Sample" configuration
4. Press `F5` to start debugging

## Services

### MySQL

- **Host**: `localhost` (or `mysql` in Dev Container)
- **Port**: 3306
- **Database**: `erupt_dev`, `erupt_test`, `erupt_sample`
- **Username**: `erupt`
- **Password**: `erupt123`

### Redis

- **Host**: `localhost` (or `redis` in Dev Container)
- **Port**: 6379
- **Password**: `redis123`

### Adminer (Optional)

- **URL**: http://localhost:8080
- **Server**: mysql
- **Username**: root
- **Password**: root123

### Redis Commander (Optional)

- **URL**: http://localhost:8081

## Troubleshooting

### Services not starting

```bash
# Check Docker status
docker ps

# View service logs
./dev-env/setup.sh logs

# Restart services
./dev-env/setup.sh restart
```

### Maven build fails

```bash
# Clean Maven cache
rm -rf ~/.m2/repository/xyz/erupt

# Rebuild
mvn clean install -DskipTests
```

### Database connection issues

```bash
# Test MySQL connection
docker exec -it erupt-mysql mysql -u erupt -perupt123 erupt_dev

# Test Redis connection
docker exec -it erupt-redis redis-cli -a redis123 ping
```

### Reset environment

```bash
# Stop and remove all data
./dev-env/setup.sh clean

# Reinitialize
./dev-env/setup.sh init
./dev-env/setup.sh start
```

## File Structure

```
dev-env/
├── docker-compose.yml          # Base Docker Compose configuration
├── .env.example                # Environment variables template
├── setup.sh                    # Development environment management script
├── maven-settings.xml          # Maven settings template
├── application-dev.yml         # Spring Boot dev profile configuration
└── init-db/
    └── 01-init.sql             # Database initialization script

.devcontainer/
├── devcontainer.json           # VSCode Dev Container configuration
├── docker-compose.devcontainer.yml  # Dev Container Docker Compose
├── Dockerfile                  # Dev Container image definition
├── post-create.sh              # Post-create setup script
└── post-start.sh               # Post-start check script
```
