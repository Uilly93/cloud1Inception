FROM mariadb:11.3

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY tools/initdb.sh /docker-entrypoint-initdb.d/00-initdb.sh
RUN chmod +x /docker-entrypoint-initdb.d/00-initdb.sh

EXPOSE 3306
