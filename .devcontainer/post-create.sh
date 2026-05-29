#!/bin/bash
# Post-create script runs once after the container is created
set -e

echo "========================================="
echo "Erupt Dev Container - Post Create Setup"
echo "========================================="

# Create workspace directories
mkdir -p /workspace/target
mkdir -p /root/.m2

# Configure Git if not already configured
if [ -z "$(git config --global user.name)" ]; then
    echo "Configuring Git..."
    git config --global user.name "Erupt Developer"
    git config --global user.email "developer@erupt.xyz"
    git config --global core.autocrlf input
    git config --global core.editor "vim"
fi

# Install Maven dependencies (pre-download common dependencies)
echo "Pre-downloading Maven dependencies..."
cd /workspace
mvn dependency:go-offline -DskipTests || echo "Warning: Some dependencies may have failed to download"

# Set proper permissions
chmod +x /workspace/dev-env/setup.sh

echo ""
echo "========================================="
echo "✓ Post-create setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Start the development services: ./dev-env/setup.sh start"
echo "2. Build the project: mvn clean install -DskipTests"
echo "3. Run tests: mvn test"
echo ""
