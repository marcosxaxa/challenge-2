#!/bin/bash

sudo yum update -y

sudo yum install mysql-server -y

sudo sed -i '/^\[mysqld\]/a port=3110' /etc/my.cnf

sudo /etc/init.d/mysqld start

cat << 'EOF' >> /tmp/user.sql
CREATE USER 'challenge'@'%' IDENTIFIED BY 'Pass-123';
GRANT ALL PRIVILEGES ON *.* TO 'challenge'@'%' IDENTIFIED BY 'Pass-123' WITH GRANT OPTION;
CREATE DATABASE challenge;
use challenge;
CREATE TABLE Persons (PersonID int, LastName varchar(255), FirstName varchar(255), Address varchar(255), City varchar(255));
EOF

sudo mysql < /tmp/user.sql