#!/bin/bash
yum -y install httpd
sed -i 's/Listen 80/Listen ${HTTP}/' /etc/httpd/conf/httpd.conf
systemctl enable httpd
systemctl start httpd
echo '<html><h1>Hello From Your Linux Web Server running on port ${HTTP}</h1></html>' > /var/www/html/index.html