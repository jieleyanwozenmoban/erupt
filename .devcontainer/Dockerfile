FROM mcr.microsoft.com/devcontainers/java:17

# Install additional packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    wget \
    git \
    unzip \
    zip \
    vim \
    less \
    tree \
    htop \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Maven (if not installed by feature)
RUN if ! command -v mvn &> /dev/null; then \
    MAVEN_VERSION=3.9.9 && \
    wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -P /tmp && \
    tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn && \
    rm /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    fi

# Configure Maven
RUN mkdir -p /root/.m2 && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' > /root/.m2/settings.xml && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"' >> /root/.m2/settings.xml && \
    echo '          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> /root/.m2/settings.xml && \
    echo '          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">' >> /root/.m2/settings.xml && \
    echo '  <mirrors>' >> /root/.m2/settings.xml && \
    echo '    <mirror>' >> /root/.m2/settings.xml && \
    echo '      <id>aliyun-maven</id>' >> /root/.m2/settings.xml && \
    echo '      <mirrorOf>central</mirrorOf>' >> /root/.m2/settings.xml && \
    echo '      <name>Aliyun Maven Mirror</name>' >> /root/.m2/settings.xml && \
    echo '      <url>https://maven.aliyun.com/repository/central</url>' >> /root/.m2/settings.xml && \
    echo '    </mirror>' >> /root/.m2/settings.xml && \
    echo '  </mirrors>' >> /root/.m2/settings.xml && \
    echo '  <profiles>' >> /root/.m2/settings.xml && \
    echo '    <profile>' >> /root/.m2/settings.xml && \
    echo '      <id>jdk-17</id>' >> /root/.m2/settings.xml && \
    echo '      <activation>' >> /root/.m2/settings.xml && \
    echo '        <activeByDefault>true</activeByDefault>' >> /root/.m2/settings.xml && \
    echo '      </activation>' >> /root/.m2/settings.xml && \
    echo '      <properties>' >> /root/.m2/settings.xml && \
    echo '        <maven.compiler.source>17</maven.compiler.source>' >> /root/.m2/settings.xml && \
    echo '        <maven.compiler.target>17</maven.compiler.target>' >> /root/.m2/settings.xml && \
    echo '        <maven.compiler.release>17</maven.compiler.release>' >> /root/.m2/settings.xml && \
    echo '      </properties>' >> /root/.m2/settings.xml && \
    echo '    </profile>' >> /root/.m2/settings.xml && \
    echo '  </profiles>' >> /root/.m2/settings.xml && \
    echo '</settings>' >> /root/.m2/settings.xml

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV MAVEN_HOME=/opt/apache-maven-3.9.9
ENV PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Install Oh My Zsh plugins
RUN if [ -d /root/.oh-my-zsh ]; then \
    sed -i 's/plugins=(git)/plugins=(git mvn docker docker-compose)/g' /root/.zshrc; \
    fi
