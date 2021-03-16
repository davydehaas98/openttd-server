FROM ubuntu:20.04
LABEL maintainer="davy.dehaas98@gmail.com"

ARG OpenTTD_VERSION="1.10.3"
ARG OPENGFX_VERSION="0.6.0"

COPY prepare.sh /tmp/prepare.sh
COPY cleanup.sh /tmp/cleanup.sh
COPY buildconfig /tmp/buildconfig
COPY --chown=1000:1000 openttd.sh /openttd.sh

RUN chmod +x /tmp/prepare.sh /tmp/cleanup.sh /openttd.sh
RUN /tmp/prepare.sh && /tmp/cleanup.sh

VOLUME /home/openttd/.openttd

EXPOSE 3979/tcp
EXPOSE 3979/udp

STOPSIGNAL 3
ENTRYPOINT [ "/usr/bin/dumb-init", "--rewrite", "15:3", "--rewrite", "9:3", "--" ]
CMD [ "/openttd.sh" ]
