# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG REGARCH
ARG REGVERSION
#
# defaults
ENV CONF_YML=/data/config.yml \
    REGISTRY_AUTH_HTPASSWD_PATH=/data/auth/.htpasswd \
    REGISTRY_AUTH_HTPASSWD_REALM=Basic-Realm \
    REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
    REGISTRY_HTTP_HOST=https://localhost:5000 \
    REGISTRY_HTTP_SECRET=such-secure-much-wow \
    REGISTRY_HTTP_TLS_CERTIFICATE=/data/auth/certificate.crt \
    REGISTRY_HTTP_TLS_KEY=/data/auth/privatekey.pem \
    REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data/storage \
    REG_ASSET_PATH=/data/web \
    REG_USER=registry \
    REG_PASS=insecurebydefault
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        apache2-utils \
        ca-certificates \
        curl \
        docker-registry \
        skopeo \
        openssl \
    && echo "using reg version: $REGVERSION" \
    && curl -Lo /usr/local/bin/reg https://github.com/genuinetools/reg/releases/download/v${REGVERSION}/reg-${REGARCH} \
    && chmod a+rx /usr/local/bin/reg \
    && apk del --purge curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /data/
#
EXPOSE 4999 5000 5001
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:4999/debug/health"} || exit 1
#
ENTRYPOINT ["/init"]
