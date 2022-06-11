FROM alpine:3.15

ARG VERSION=0.0.0
ENV VERSION=${VERSION}

LABEL version="${VERSION}" \
    description="MySQL client for easy export and import databases using Docker." \
    maintainer="Jose Quintana <joseluisq.net>"

# Dependencies
ENV BUILD_DEPS="gettext"
ENV RUNTIME_DEPS="libintl"
ARG ENVE_VERSION=1.4.0

# Custom user
ARG USER_NAME
ARG USER_HOME_DIR

ENV USER_NAME=${USER_NAME:-mysql}
ENV USER_HOME_DIR=${USER_HOME_DIR:-/home/${USER_NAME}}

COPY ./download_enve.sh ./
RUN set -eux \
    && adduser -h ${USER_HOME_DIR} -s /sbin/nologin -u 1000 -D ${USER_NAME} \
    && apk --no-cache add ca-certificates tzdata mysql-client nano dumb-init \
    && apk add --update $RUNTIME_DEPS \
    && apk add --virtual build_deps $BUILD_DEPS \
    && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && apk del build_deps \
    && /bin/sh ./download_enve.sh ${ENVE_VERSION} \
	&& tar xzvf /tmp/enve.tar.gz -C /usr/local/bin enve \
	&& enve -v \
	&& rm -rf /tmp/enve.tar.gz \
	&& chmod +x /usr/local/bin/enve \
    && true

COPY ./__mysqldump.sh /usr/local/bin/__mysqldump.sh
COPY ./mysql_exporter /usr/local/bin/mysql_exporter
COPY ./__mysqlimport.sh /usr/local/bin/__mysqlimport.sh
COPY ./mysql_importer /usr/local/bin/mysql_importer

RUN set -eux \
    && chmod +x /usr/local/bin/__mysqldump.sh \
    && chmod +x /usr/local/bin/__mysqlimport.sh \
    && chmod +x /usr/local/bin/mysql_exporter \
    && chmod +x /usr/local/bin/mysql_importer \
    && true

USER ${USER_NAME}

WORKDIR ${USER_HOME_DIR}

VOLUME ${USER_HOME_DIR}

ENTRYPOINT [ "/usr/bin/dumb-init" ]

CMD [ "mysql" ]

# Metadata
LABEL org.opencontainers.image.vendor="Air Solution" \
    org.opencontainers.image.url="https://github.com/arimorc/alpine-mysql-client" \
    org.opencontainers.image.title="Alpine / MySQL Client" \
    org.opencontainers.image.description="MySQL client for easy export and import databases using Docker." \
    org.opencontainers.image.version="v${VERSION}" \
    org.opencontainers.image.documentation="https://github.com/arimorc/alpine-mysql-client/blob/master/README.md"
