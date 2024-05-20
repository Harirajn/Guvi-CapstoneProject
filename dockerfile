
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y nginx nodejs npm

COPY volumes/app/ /usr/share/nginx/html/

WORKDIR /usr/share/nginx/html/server/
RUN npm install

COPY default /etc/nginx/sites-enabled/default


EXPOSE 80
EXPOSE 3000

CMD ["sh", "-c", "nginx -g 'daemon off;' & node /usr/share/nginx/html/server/server.js"]
