FROM ubuntu:20.04
LABEL maintainer="davy.dehaas98@gmail.com"
# Initial Versions, will change in the pipeline depending on what version is needed to build
ARG OPENTTD_VERSION="1.10.3"
ARG OPENGFX_VERSION="0.6.0"
# Copy buildconfig file and scripts
COPY buildconfig /tmp/buildconfig
COPY prepare.sh /tmp/prepare.sh
COPY cleanup.sh /tmp/cleanup.sh
COPY --chown=1000:1000 openttd.sh /openttd.sh
# Fix permissions
RUN chmod +x /tmp/prepare.sh /tmp/cleanup.sh /openttd.sh
# Run prepare with buildconfig and cleanup
RUN /tmp/prepare.sh && /tmp/cleanup.sh
# Make volume available for outside the container
VOLUME /home/openttd/.openttd

EXPOSE 3979/tcp
EXPOSE 3979/udp

STOPSIGNAL 3
ENTRYPOINT [ "/usr/bin/dumb-init", "--rewrite", "15:3", "--rewrite", "9:3", "--" ]
CMD [ "/openttd.sh" ]
