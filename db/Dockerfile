FROM mysql:5.6

ARG DUMPDATE
ARG DUMP_SERVER_VERSION
ARG MYSQL_ROOT_PASSWORD
ARG MYSQL_USER=people
ARG MYSQL_PASSWORD
ARG MYSQL_DATABASE=people
ARG TZ=MST7MDT

ENV DUMP_SERVER_VERSION=${DUMP_SERVER_VERSION} \
    DUMPDATE=${DUMPDATE} \
    MYSQL_DATABASE=${MYSQL_DATABASE} \
    TZ=${TZ} \
    MYSQL_USER=${MYSQL_USER}
LABEL dumpdate=${DUMPDATE}
LABEL dump_server_version=${DUMP_SERVER_VERSION}

COPY entrypoint.sh /usr/local/bin/
COPY mysql.sh healthcheck.sh /usr/local/bin/
COPY mysqld-init.sh /usr/local/bin/

COPY PEOPLEDB.sql docker-entrypoint-initdb.d/

RUN MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} ; \
    MYSQL_PASSWORD=${MYSQL_PASSWORD} ; \
    export MYSQL_ROOT_PASSWORD MYSQL_PASSWORD ; \
    /usr/local/bin/mysqld-init.sh

ENTRYPOINT ["entrypoint.sh"]
HEALTHCHECK --interval=20s --timeout=10s --retries=3 CMD healthcheck.sh

EXPOSE 3306
VOLUME /run/secrets /var/lib/mysql

CMD [ "mysqld" ]


