FROM amancevice/pandas:0.20.3-python3

# Superset version
ARG SUPERSET_VERSION=0.24.0

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/home/superset \
    SUPERSET_COMPLETE=/var/local

# Configure Filesysten
WORKDIR /home/superset

# Install dependencies & create superset user
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libsasl2-dev \
        libldap2-dev \
        mariadb-client \
        postgresql-client && \
    pip install \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        impyla==0.14.0 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyhive==0.2.1 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        sqlalchemy-clickhouse==0.1.2.post3 \
        superset==$SUPERSET_VERSION \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -U superset && \
    mkdir /home/superset/.superset && \
    touch /home/superset/.superset/superset.db && \
    chown root:staff /usr/local/bin/superset* && \
    chown -R superset:superset /home/superset

COPY superset/init.sh ./init.sh
RUN chmod +x ./init.sh

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]

ENTRYPOINT ["./init.sh"]
USER superset
