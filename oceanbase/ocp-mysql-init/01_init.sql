-- MySQL will create DB/user via env; this ensures idempotency and extras.
CREATE DATABASE IF NOT EXISTS ocp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'ocp'@'%' IDENTIFIED BY 'ocp123456';
GRANT ALL PRIVILEGES ON ocp.* TO 'ocp'@'%';
FLUSH PRIVILEGES;


