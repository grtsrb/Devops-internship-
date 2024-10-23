#!/bin/bash


# Update Ubuntu repository
sudo apt update
# Install needed packages:
#
#

sudo apt install -y nginx mysql-server php8.3-fpm php8.3-mysql 

# Start 
#
#

sudo systemctl start nginx
sudo systemctl start mysql
sudo systemctl start php8.3-fpm

# Create database
#
#

read -p "Enter your database name: " database_name
read -s -p "Enter root password: " root_password

echo "Creating MySQL database..."
sudo mysql -uroot -p${root_password} -e "CREATE DATABASE ${database_name};"
echo "Database created sucessfully!"
echo "Showing existing databases.."

sudo mysql -uroot -p${root_password} -e "show databases;"

# Creating new user and granting him the permission
#
#

echo ""
echo ""

read -p "Enter your the name of the new MySQL database user: " db_username
read -s -p "Enter password for the new user (NOTE: Password will be hidden): " user_password

sudo mysql -uroot -p${root_password} -e "DROP USER IF EXISTS '${db_username}'@'localhost';"
sudo mysql -uroot -p${root_password} -e "CREATE USER '${db_username}'@'localhost' IDENTIFIED BY '${user_password}';"
echo "User created sucessfully!"

echo ""

echo "Granting all privileges on ${database_name} to ${db_username}"
sudo mysql -uroot -p${root_password} -e "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${db_username}'@'localhost';"

# Refresh privileges
#
#

sudo mysql -uroot -p${root_password} -e "FLUSH PRIVILEGES;"

# Enter tmp folder, where nginx_base.conf will be
#
#

cd /tmp

# Generate Nginx configuration base
#
#

touch nginx_base.conf

cat <<EOT >> nginx_base.conf
		# Add this under your server context in /etc/nginx/nginx.conf
 		index index.php;

                location / {
                        try_files $uri $uri/ /index.php?$args;
                }

                location ~ \.php$ {
                   #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                        include fastcgi_params;
                        fastcgi_intercept_errors on;
                        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
                        fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
}
EOT

# Download wordpress and extract it to /var/www/html
#
#

sudo rm -rf /var/www/html/wordpres

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar xf latest.tar.gz
sudo mv wordpress /var/www/html/
rm latest.tar.gz

cd /var/www/html/wordpress

sudo mv wp-config-sample.php wp-config.php

sudo chown -R www-data:www-data /var/www/html/wordpress

# Change wp-config to our db info
#
#

sudo sed -i "s/database_name_here/${database_name}/" wp-config.php
sudo sed -i "s/username_here/${db_username}/" wp-config.php
sudo sed -i "s/password_here/${user_password}/" wp-config.php
