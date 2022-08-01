FROM nginx:stable-alpine

RUN sed -i "s/user  nginx/user root/g" /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html

ADD ./testing.museumofthefuture.ae /etc/nginx/conf.d/default.conf


