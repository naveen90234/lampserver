#!/bin/bash

# Update the package list
sudo apt update

# Install Apache
sudo apt install -y apache2
sudo systemctl enable --now apache2

# Install MySQL and set root password
echo 'mysql-server mysql-server/root_password password root' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password root' | sudo debconf-set-selections
sudo apt install -y mysql-server

# Install PHP and required modules
sudo apt install php8.0 php8.0-fpm php8.0-mysql php-common php8.0-cli php8.0-common php8.0-opcache php8.0-readline php8.0-mbstring php8.0-xml php8.0-gd php8.0-curl --no-install-recommends -y

# Restart Apache to apply changes
sudo systemctl restart apache2

# Install phpMyAdmin and configure Apache to use it
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | sudo debconf-set-selections
sudo apt install -y phpmyadmin

# Enable the phpMyAdmin Apache configuration
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin

# Restart Apache to apply changes
sudo systemctl restart apache2

# Create a new MySQL user and database for phpMyAdmin
MYSQL_ROOT_PASSWORD="root"
PHPMYADMIN_PASSWORD="root"

sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
CREATE DATABASE phpmyadmin;
CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$PHPMYADMIN_PASSWORD';
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

echo "LAMP server and phpMyAdmin setup completed successfully."

