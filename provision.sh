#!/bin/bash

#pre-requisites
yum install java-1.8.0-openjdk-devel -y
yum install nginx -y 

#user without login shell
useradd subroot
chsh -s /sbin/nologin subroot

#downloading build from S3 bucket
mkdir /opt/springboot-app
aws s3 cp s3://${s3_bucket_name}/ /opt/springboot-app/ --no-sign-request --region=${region} --recursive --exclude "*" --include "springboot-app*.jar"
mv /opt/springboot-app/springboot-app*.jar /opt/springboot-app/springboot-app.jar

cat << EOF > /opt/springboot-app/springboot-app.conf
RUN_ARGS="--spring.datasource.url=jdbc:mysql://${database_endpoint}/${database_name}?useSSL=false --spring.datasource.password=${database_password}"
EOF

#Permission
chmod 700 /opt/springboot-app/springboot-app.conf
chown subroot:subroot /opt/springboot-app/springboot-app.conf

#creating Nginx conf file for springboot-appication
cat << EOF > /etc/nginx/conf.d/sprintboot-app.conf
server {
    listen 80 default_server;

    # Redirect if the protocol used by the client of the AWS application load balancer was not HTTPS
    if (\$http_x_forwarded_proto != 'https') {
        return 301 https://\$host\$request_uri;
    }

    location / {
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$http_host;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass          http://127.0.0.1:8080;
    }
}
EOF

#Modifying the default NGinx.conf file
cat << EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
    index   index.html index.htm;
}
EOF

chown subroot:subroot /opt/springboot-app/springboot-app.jar
chmod 500 /opt/springboot-app/springboot-app.jar

ln -s /opt/springboot-app/springboot-app.jar /etc/init.d/springboot-app

chkconfig nginx on
chkconfig springboot-app on

service nginx start
service springboot-app start