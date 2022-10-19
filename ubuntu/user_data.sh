#!/bin/bash
apt install -y apache2
systemctl enable --now httpd 
echo '<html><h1>Bye From Your Linux Web Server!</h1></html>' > /var/www/html/index.html