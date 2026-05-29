-- Erupt Development Database Initialization Script
-- This script runs automatically when MySQL container starts for the first time

-- Create additional databases for different environments
CREATE DATABASE IF NOT EXISTS `erupt_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `erupt_sample` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges
GRANT ALL PRIVILEGES ON `erupt_dev`.* TO 'erupt'@'%';
GRANT ALL PRIVILEGES ON `erupt_test`.* TO 'erupt'@'%';
GRANT ALL PRIVILEGES ON `erupt_sample`.* TO 'erupt'@'%';
FLUSH PRIVILEGES;

-- Set default character set for existing databases
ALTER DATABASE `erupt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE `erupt_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE `erupt_sample` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
