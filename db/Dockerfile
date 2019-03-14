FROM mysql:5.6

ARG DUMPDATE
ENV DUMPDATE=${DUMPDATE}
ENV MYSQL_DATABASE=people \
    TZ=MST7MDT
LABEL dumpdate=${DUMPDATE}

COPY entrypoint.sh /usr/local/bin/
COPY mysql.sh healthcheck.sh versions.sh /usr/local/bin/
COPY PEOPLE-prod.sql docker-entrypoint-initdb.d/

ENTRYPOINT ["entrypoint.sh"]
HEALTHCHECK --interval=20s --timeout=10s --retries=3 CMD healthcheck.sh

EXPOSE 3306

CMD [ "mysqld" ]


