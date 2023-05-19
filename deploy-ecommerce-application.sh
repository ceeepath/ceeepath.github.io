#!/bin/bash
read -sp 'Enter your password: ' PASSWORD

#Install Firewall
echo $PASSWORD | sudo yum update -y
echo $PASSWORD | sudo yum install -y firewalld
sleep 15
echo $PASSWORD | sudo service firewalld start
echo $PASSWORD | sudo systemctl enable firewalld

#Install MariaDB
echo $PASSWORD | sudo yum install -y mariadb-server
sleep 15
echo $PASSWORD | sudo service mariadb start
echo $PASSWORD | sudo systemctl enable mariadb

#Install and Configure Webservers
echo $PASSWORD | sudo yum install -y httpd php php-mysql
sleep 15
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#Configure firewall for Database and Webservers
echo $PASSWORD | sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
echo $PASSWORD | sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
echo $PASSWORD | sudo firewall-cmd --reload

#Configure Database
mysql << EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF

#Create the db-load-script.sql
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

#Run sql script
mysql < db-load-script.sql

#Start Webservers
echo $PASSWORD | sudo service httpd start
echo $PASSWORD | sudo systemctl enable httpd

#Clone Source Code
echo $PASSWORD | sudo yum install -y git
git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

#Update index.php with database connection
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

#Test the website
curl http://localhost
