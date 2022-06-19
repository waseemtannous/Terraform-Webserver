FROM postgres

ENV POSTGRES_PASSWORD password
ENV POSTGRES_DB jokes

EXPOSE 5432

COPY jokes.sql /docker-entrypoint-initdb.d/

# docker build -t database .
# docker build -t gcr.io/terraform-webserver-dev/database .
# docker run -d --name mydb -p 5432:5432 database